{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "stable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # Private common modules
    common.url = "../common";

    # Utilities
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    common,
    nixos-hardware,
    ...
  }:
  let
    overlays = [
      (final: prev: {
        stable = import inputs.stable {
          system = final.system;
          config.allowUnfree = true;
        };

        unstable = import inputs.unstable {
          system = final.system;
          config.allowUnfree = true;
        };

        master = import inputs.master {
          system = final.system;
          config.allowUnfree = true;
          config.permittedInsecurePackages = [ "snapmaker-luban-4.9.1" "electron-25.9.0" ];
        };
      })
    ];
  in
  {
    nixosConfigurations = {
      artemis = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        pkgs = (import nixpkgs) {
          system = "x86_64-linux";

          config = {
            allowUnfree = true;
          };

          overlays = overlays;
        } // { outPath = nixpkgs.outPath; };

        modules = [
          # Host
          ./host.nix
          common.nixosModules.configuration.common

          # DE/WM
          common.nixosModules.desktop.kde

          # Applications
          common.nixosModules.applications.dev.vscodium
          common.nixosModules.applications.gaming.steam
          
          # Services
          common.nixosModules.services.avahi
          common.nixosModules.services.clamav
          common.nixosModules.services.gpg-agent
          common.nixosModules.services.printing

          ({ pkgs, ... }:
          {
            environment.systemPackages = with pkgs; [
              # Browsers
              unstable.brave
              unstable.firefox

              # Media
              unstable.spotify
              vlc

              # Social
              master.discord

              # Dev tools
              master.jetbrains.clion
              master.jetbrains.pycharm-professional
              master.jetbrains.webstorm
              master.jetbrains.rider
              master.jetbrains.rust-rover

              # Note taking
              master.obsidian

              # Making
              inkscape
            ];
          })
        ];
      };
    };
  };
}

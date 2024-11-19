{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "unstable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";
    #extras.url = "github:simonkampe/nixpkgs/extras";

    # Private common modules
    common.url = "../common";

    # Utilities
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    tosibox-key = {
      url = "path:/home/simon/Workspace/Personal/NixOS/apollo/external/tosibox-key";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    common,
    nixos-hardware,
    tosibox-key,
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
          config.permittedInsecurePackages = [
            "olm-3.2.16" # Nheko
          ];
        };

        #extras = import inputs.extras {
        #  system = final.system;
        #  config.allowUnfree = true;
        #};
      })
    ];
  in
  {
    nixosConfigurations = {
      apollo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        pkgs = (import nixpkgs) {
          system = "x86_64-linux";

          config = {
            allowUnfree = true;
          };

          inherit overlays;
        } // { outPath = nixpkgs.outPath; };

        modules = [
          # Host
          ./host.nix
          common.nixosModules.configuration.common

          # DE/WM
          common.nixosModules.desktop.kde

          # Configuration
          common.nixosModules.configuration.cross-aarch64-linux

          # Applications
          common.nixosModules.applications.dev.vmware-workstation
          common.nixosModules.applications.virtualisation.qemu
          common.nixosModules.applications.gaming.steam
          
          # Services
          common.nixosModules.services.avahi
          common.nixosModules.services.clamav
          common.nixosModules.services.gpg-agent
          common.nixosModules.services.printing

          # Hardware
          nixos-hardware.nixosModules.lenovo-thinkpad-p1-gen3

          ({ pkgs, lib, ... }:
          {
            programs.adb.enable = true;

            virtualisation.docker.enable = true;

            security.polkit.enable = true;

            services = {
              tailscale.enable = true;
              flatpak.enable = true;
              fwupd.enable = true;

              udev.packages = [ tosibox-key.packages.x86_64-linux.tosiboxkey ];
            };

            security.sudo.extraConfig = ''
              %wheel ALL=(root) NOPASSWD: ${tosibox-key.packages.x86_64-linux.tosiboxkey}/bin/openvpn
            '';

            environment.systemPackages = with pkgs; [
              # Browsers
              unstable.brave
              unstable.chromium

              # Office
              unstable.onlyoffice-bin_latest

              # Graphics
              inkscape
              aseprite

              # Media
              unstable.spotify
              vlc

              # Social
              master.discord
              master.nheko

              # Dev tools
              unstable.jetbrains.clion
              unstable.jetbrains.pycharm-professional
              unstable.jetbrains.webstorm
              unstable.jetbrains.rider
              unstable.jetbrains.rust-rover
              unstable.jetbrains.idea-ultimate
              unstable.jetbrains.datagrip
              (unstable.vscodium.fhsWithPackages (ps: with ps; [
                nodejs
                stdenv.cc.cc.lib
                dotnetCorePackages.sdk_6_0
              ]))

              # Note taking
              unstable.obsidian

              # Tooling
              unstable.wireshark
              unstable.sniffnet
              unstable.teamviewer
              tosibox-key.packages.x86_64-linux.tosiboxkey
            ];
          })
        ];
      };
    };
  };
}

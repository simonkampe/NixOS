{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "stable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # Private common modules
    common.url = "../common";
    
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    common,
    nixos-hardware,
    disko,
    ...
  }:
  {
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
        };
      })
    ];

    defaultPackage."x86_64-linux" = self.nixosConfigurations.zeus.config.system.build.sdImage;

    nixosConfigurations = {
      zeus = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        pkgs = (import nixpkgs) {
          system = "aarch64-linux";

          config = {
            allowUnfree = true;
          };

          overlays = self.overlays;
        } // { outPath = nixpkgs.outPath; };
        
        modules = [
          nixos-hardware.nixosModules.raspberry-pi-4

          ./host.nix
          ./rpi4.nix
          ./sd-image.nix

          common.nixosModules.hardware.argoneon

          common.nixosModules.configuration.common

          common.nixosModules.services.home-assistant
          #common.nixosModules.services.pihole
          common.nixosModules.services.clamav
          common.nixosModules.services.avahi

          ({ pkgs, ... }:
          {
            services.tailscale.enable = true;

            services.jellyfin = {
              enable = true;
              openFirewall = true;
            };
            
            environment.systemPackages = with pkgs; [
              jellyfin
              jellyfin-web
              jellyfin-ffmpeg
            ];
          })
        ];
      };
    };
  };
}

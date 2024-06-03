{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "stable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-inspect.url = "github:bluskript/nix-inspect";
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    ...
  }:
  let
    inherit (builtins) attrValues;
  in
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
          config.permittedInsecurePackages = [ "snapmaker-luban-4.9.1" "electron-25.9.0" ];
        };
      })
    ];

    homeConfigurations = {
      simon = home-manager.lib.homeManagerConfiguration {
        pkgs = (import inputs.unstable) {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = self.overlays;
        };

        modules = [
          ./simon.nix
          ./devtools.nix
          ./helix.nix
          ./office.nix

          ({ pkgs, ... }:
          {
            home.packages = with pkgs; [
              tela-icon-theme
              qogir-icon-theme # Qogir cursors
              libsForQt5.lightly
              inputs.nix-inspect.packages.x86_64-linux.default
            ];
          })
        ];

      };
    };
  };
}

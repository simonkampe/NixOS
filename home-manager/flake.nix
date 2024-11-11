{
  description = "";

  inputs = {
    # System
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-inspect = {
      url = "github:bluskript/nix-inspect";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    nix-inspect,
    agenix,
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
        pkgs = (import nixpkgs) {
          system = "x86_64-linux";
          config.allowUnfree = true;
          overlays = self.overlays;
        };

        modules = [
          agenix.homeManagerModules.age

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
              nix-inspect.packages.x86_64-linux.default
              agenix.packages."${system}".default
            ];
          })
        ];
      };
    };
  };
}

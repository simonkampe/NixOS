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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-treesitter = {
      url = "github:ratson/nix-treesitter";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    home-manager,
    agenix,
    nix-treesitter,
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
          config.permittedInsecurePackages = [ ];
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
          ./git.nix
          ./shell.nix
          ./helix.nix

          ({ pkgs, ... }:
          {
            home.packages = with pkgs; [
              tela-icon-theme
              qogir-icon-theme # Qogir cursors
              libsForQt5.lightly
              agenix.packages.${system}.default
              nix-treesitter.packages.${system}.tree-sitter-structured-text
            ];
          })
        ];
      };
    };
  };
}

{
  description = "";

  inputs = {
    # System
    nixpkgs.follows = "unstable";

    # Extra channels
    stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    master.url = "github:NixOS/nixpkgs/master";

    # Utilities
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
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
    nixos-hardware,
    home-manager,
    agenix,
    ...
  }:
  let
    overlays = [
      (final: prev: {
        stable = import inputs.stable {
          system = final.system;
          allowUnfree = true;
        };

        unstable = import inputs.unstable {
          system = final.system;
          allowUnfree = true;
        };

        master = import inputs.master {
          system = final.system;
          allowUnfree = true;
        };

        agenix = agenix.packages.${final.system}.default;
      })

      inputs.hyprpanel.overlay
    ];
  in
  {
    nixosConfigurations = {
      optimus = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        pkgs = (import nixpkgs) {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
            config.permittedInsecurePackages = [
              "dotnet-sdk-7.0.410"
            ];
          };
          inherit overlays;
        } // { outPath = nixpkgs.outPath; };

        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.simon = import ./home/simon.nix;
            home-manager.extraSpecialArgs = { inherit agenix; };
          }

          agenix.nixosModules.default
        ];
      };
    };
  };
}

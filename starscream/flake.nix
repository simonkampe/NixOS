{
  description = "";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

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
      url = "github:simonkampe/HyprPanel?ref=ws_mon_fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    tosibox-key = {
      url = "git+ssh://simon@zeus/data/git/tosibox-key.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    apax-cli = {
      url = "git+ssh://simon@zeus/data/git/apax.git?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    agenix,
    tosibox-key,
    apax-cli,
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
        };

        tosibox = inputs.tosibox-key.packages.${final.system}.default;
        apax = inputs.apax-cli.packages.${final.system}.apax;
        agenix = agenix.packages.${final.system}.default;

        intel-npu-driver = import ./pkgs/intel-npu-driver.nix { pkgs = final; };
      })

      inputs.hyprpanel.overlay
    ];
  in
  {
    nixosConfigurations = {
      starscream = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        pkgs = (import nixpkgs) {
          system = "x86_64-linux";

          config = {
            allowUnfree = true;
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
            home-manager.extraSpecialArgs = { inherit inputs; };
          }

          inputs.tosibox-key.nixosModules.tosibox-key
        ];
      };
    };
  };
}

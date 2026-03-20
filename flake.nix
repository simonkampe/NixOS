{
  description = "My NixOS configurations";

  inputs = {
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "unstable";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "unstable";
    };

    tosibox-key = {
      #url = "git+ssh://simon@zeus/data/git/tosibox-key.git?ref=main";
      #url = "git+ssh://git@gitlab.com/esab/abw/tosibox-key.git?ref=flake";
      url = "path:///data/Workspace/Personal/tosibox-key/";
      inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = { home-manager, ... }@inputs:
  let
    mkSystem = { nixpkgs, system, hostName, headless?false }:
      let
        pkgs = import nixpkgs {
          system = system;
        } // { outPath = nixpkgs.outPath; };

      in nixpkgs.lib.nixosSystem {
        system = system;

        modules = [
          { networking.hostName = hostName; }
          { nixpkgs.config.allowUnfree = true; }

          # Base configuration
          ./configuration/base-configuration.nix

        ]
        ++ nixpkgs.lib.optional (!headless) (./. + "/configuration/withgui-configuration.nix") ++
        [
          # Host specific configuration
          (./. + "/hosts/${hostName}/configuration.nix")
          (./. + "/hosts/${hostName}/hardware-configuration.nix")

          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit pkgs inputs; };
              users.simon = (./. + "/hosts/${hostName}/user.nix");
            };
          }
        ];

        specialArgs = { inherit inputs; };
      };
  in {
    nixosConfigurations = {
      starscream = mkSystem {
        nixpkgs = inputs.unstable;
        system = "x86_64-linux";
        hostName = "starscream";
      };
      optimus = mkSystem {
        nixpkgs = inputs.unstable;
        system = "x86_64-linux";
        hostName = "optimus";
      };
    };
  };
}
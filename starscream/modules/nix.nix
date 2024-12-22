{ inputs, config, lib, pkgs, ... }:

{
  nix =
  let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
      nix-path = config.nix.nixPath;
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
    };

    channel.enable = false;

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
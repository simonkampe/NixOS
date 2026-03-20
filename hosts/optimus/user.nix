{ config, lib, inputs, pkgs, ... }:

{
    imports = [
      ../../modules/home/default.nix
    ];

    config = {
      modules.home = {
        git.enable = true;
        gpg.enable = true;
        helix.enable = true;
        jj.enable = true;
        shell = {
          enable = true;
          prependInit = ''
          '';
        };
      };

      xdg = {
        enable = true;
      };

      home.stateVersion = "22.05";
    };
}
{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.home.direnv;
in {
  options.modules.home.direnv = {
    enable = mkEnableOption "direnv";
  };

  config = lib.mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.dev.docker;
in {
  options.modules.system.dev.docker = {
    enable = mkEnableOption "docker";

    user = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation = {
      docker.enable = true;
    };

    users.users.${cfg.user}.extraGroups = ["docker"];
  };
}
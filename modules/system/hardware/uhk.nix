{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.hardware.uhk;
in {
  options.modules.system.hardware.uhk = {
    enable = mkEnableOption "uhk";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.uhk = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      uhk-agent
    ];
  };
}
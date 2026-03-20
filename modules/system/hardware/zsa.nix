{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.hardware.zsa;
in {
  options.modules.system.hardware.zsa = {
    enable = mkEnableOption "zsa";
  };

  config = lib.mkIf cfg.enable {
    hardware.keyboard.zsa = {
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      wally-cli
    ];
  };
}
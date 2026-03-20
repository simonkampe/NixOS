{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.programs.wireshark;
in {
  options.modules.system.programs.wireshark = {
    enable = mkEnableOption "wireshark";

    user = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
    };

    users.users.${cfg.user}.extraGroups = ["wireshark"];
  };
}
{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.hardware.buspirate;
in {
  options.modules.system.hardware.buspirate = {
    enable = mkEnableOption "buspirate";
  };

  config = lib.mkIf cfg.enable {
    services.udev.extraRules = ''
      # Bus pirate v6
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7331", ENV{ID_USB_INTERFACE_NUM}=="00", TAG+="uaccess", SYMLINK+="buspirate-text", ENV{ID_SIGROK}+="1"
      SUBSYSTEM=="tty", ATTRS{idVendor}=="1209", ATTRS{idProduct}=="7331", ENV{ID_USB_INTERFACE_NUM}=="02", TAG+="uaccess", SYMLINK+="buspirate-binary", ENV{ID_SIGROK}+="1"
    '';
  };
}


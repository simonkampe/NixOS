{ config, lib, pkgs, ...}:

with lib;
let
  cfg = config.services.argoneon;
in {
  options.services.argoneon = {
    enable = mkEnableOption "Enable Argon EON services" // { default = true; };
    package = mkOption {
      type = types.package;
    };
    withFanControl = mkEnableOption "Enable case fan control" // { default = true; };
    withOledDisplay = mkEnableOption "Enable OLED display" // { default = true; };
    withPowerButton = mkEnableOption "Enable power button handling" // { default = true; };
  };
  
  config = mkIf cfg.enable {
    # I2C
    hardware.i2c.enable = true;

    users.groups.gpio = {};
    services.udev.extraRules = ''
      SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
      SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
      SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
    '';

    hardware = {
      raspberry-pi."4".apply-overlays-dtmerge.enable = true;
      #raspberry-pi."4".i2c0.enable = true;
      raspberry-pi."4".i2c1.enable = true;
      deviceTree = {
        enable = true;
        filter = "*rpi-4-*.dtb";
      };
    };

    hardware.deviceTree.overlays = [];

    environment.systemPackages = with pkgs; [
      argon
      libraspberrypi
      raspberrypi-eeprom
      smartmontools
      i2c-tools
    ];

    boot.loader.raspberryPi.firmwareConfig = ''
      PSU_MAX_CURRENT=5000
    '';

    systemd.services.argon-fancontrol = mkIf cfg.withFanControl {
      description = "Argon Raspberry Pi enclosure fan control service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/argon-fancontrol SERVICE";
        PIDFile = "/run/argon-fancontrol.pid";
        Restart = "on-failure";
      };
    };

    systemd.services.argon-oled = mkIf cfg.withOledDisplay {
      description = "Argon Raspberry Pi enclosure oled display service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/argon-oled";
        PIDFile = "/run/argon-oled.pid";
        Restart = "on-failure";
      };
    };

    systemd.services.argon-powerbutton = mkIf cfg.withPowerButton {
      description = "Argon Raspberry Pi enclosure powerbutton service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/argon-powerbutton SERVICE";
        PIDFile = "/run/argon-powerbutton.pid";
        Restart = "on-failure";
      };
    };
  };
}

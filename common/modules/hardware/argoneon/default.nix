{ config, lib, pkgs, ...}:
{
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

  systemd.services.argon-fancontrol = {
    description = "Argon Raspberry Pi enclosure fan control service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${argon}/bin/argon-fancontrol SERVICE";
      PIDFile = "/run/argon-fancontrol.pid";
      Restart = "on-failure";
    };
  };

  systemd.services.argon-oled = {
    description = "Argon Raspberry Pi enclosure oled service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${argon}/bin/argon-oled";
      PIDFile = "/run/argon-oled.pid";
      Restart = "on-failure";
    };
  };

  systemd.services.argon-powerbutton = {
    description = "Argon Raspberry Pi enclosure powerbutton service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${argon}/bin/argon-powerbutton SERVICE";
      PIDFile = "/run/argon-powerbutton.pid";
      Restart = "on-failure";
    };
  };
  
}

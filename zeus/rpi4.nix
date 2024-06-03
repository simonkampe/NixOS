{ config, lib, pkgs, modulesPath, inputs, ... }:
{
  boot = {
    kernelPackages = pkgs.linuxPackages;
    tmp.useTmpfs = true;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" "uas" ];

    kernelParams = [
      "8250.nr_uarts=1"
      "console=ttyAMA0,115200"
      "console=tty1"
      "cma=128M"
    ];
  };

  boot.growPartition = true; # Maximize the root partition on boot

  nixpkgs = {
    # Define that we need to build for ARM
    localSystem = {
      system = "aarch64-linux";
      config = "aarch64-unknown-linux-gnu";
    };
  };

  environment.systemPackages = with pkgs; [
    raspberrypi-eeprom
    libraspberrypi
  ];

  # From nixos-hardware
  hardware.raspberry-pi."4" = {
    apply-overlays-dtmerge.enable = true;
    fkms-3d.enable = false;
  };
}

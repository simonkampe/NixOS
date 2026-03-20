{ config, lib, pkgs, modulesPath, ... } :

{
  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  security.rtkit.enable = true;

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };

  boot = {
    kernelPackages = pkgs.linuxPackages;

    supportedFilesystems = [ "ntfs" "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;

    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "ahci" "usbhid" "usb_storage" "uas" "sd_mod" ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" =
  {
    device = "/dev/disk/by-uuid/a67d0add-e227-4b50-bda1-c0ed146072e8";
    fsType = "ext4";
  };

  fileSystems."/boot" =
  {
    device = "/dev/disk/by-uuid/E399-8371";
    fsType = "vfat";
  };

  fileSystems."/data" =
  {
    device = "/dev/disk/by-label/data1";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  swapDevices =
  [
    { device = "/dev/disk/by-uuid/59d48ca4-8b3e-4a64-9e1a-2ea17617d006"; }
  ];
}
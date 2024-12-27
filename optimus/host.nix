{ config, pkgs, lib, modulesPath, ... }:
{
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    
    nvidia = {
      prime.offload.enable = false;
      powerManagement.enable = true;
      open = false;
    };

    opengl = {
      enable = true;
      driSupport32Bit = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?


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

  networking.firewall.enable = false;

  ##############
  # Sound
  ##############

  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
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
  
  swapDevices =
  [
    { device = "/dev/disk/by-uuid/59d48ca4-8b3e-4a64-9e1a-2ea17617d006"; }
  ];

  fileSystems."/data" =
  {
    device = "/dev/disk/by-label/data1";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  ##############
  # Video
  ##############
  services.xserver.videoDrivers = [ "nvidia" ];
}


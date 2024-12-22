{ config, lib, pkgs, modulesPath, ... } :

{
  console.keyMap = "sv-latin1";

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

      powerManagement.enable = false;

      powerManagement.finegrained = true;

      open = false;

      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        intelBusId = "PCI:0:0:0";
        nvidiaBusId = "PCI:1:1:1";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        sync = {
          enable = false;
        };
      };
    };
  };

  security.rtkit.enable = true;
  services = {
    hardware.bolt.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
    };

    xserver.videoDrivers = [ "nvidia" ];
  };

  boot = {
    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages;

    supportedFilesystems = [ "ntfs" "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;

    kernel.sysctl = { "net.ipv4.ip_local_port_range" = "49152 60999"; };
  };

  imports =
      [ (modulesPath + "/installer/scan/not-detected.nix")
      ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/331bd8a9-fc5a-4c63-950a-b72cb620c43f";
        fsType = "ext4";
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/783A-7EE1";
        fsType = "vfat";
      };

    fileSystems."/data" =
      { device = "/dev/disk/by-label/data";
        fsType = "auto";
        options = [ "defaults" "nofail" "compress=zstd:1" "commit=120" "ssd" "acl" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-uuid/9052965d-f010-4606-a837-b52676963706"; }
      ];
}
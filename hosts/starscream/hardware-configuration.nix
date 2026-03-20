{ config, lib, pkgs, modulesPath, ... } :

{
  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;

      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
      ];
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = true;
      open = false;
      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;

      prime = {
        # Bus ID of the Intel GPU.
        intelBusId = lib.mkDefault "PCI:0:2:0";
        # Bus ID of the NVIDIA GPU.
        nvidiaBusId = lib.mkDefault "PCI:1:0:0";

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

    xserver.videoDrivers = [ "nvidia" ];
  };

  boot = {
    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages_latest;

    kernelModules = [ "kvm-intel" ];

    supportedFilesystems = [ "ntfs" "nfs" ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];

      kernelModules = [ "dm-snapshot" "cryptd" "i915" ];

      luks.devices = {
        "cryptroot".device = "/dev/disk/by-label/luksroot";
        "cryptdata".device = "/dev/disk/by-uuid/05d52f0b-81c6-4cd2-93a7-4ef77ab656e6";
      };

      systemd.enable = true;
    };

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
      { device = "/dev/disk/by-label/root";
        fsType = "btrfs";
        options = [
          "compress=zstd"
          "space_cache=v2"
          "noatime"
          "commit=120"
        ];
      };

    fileSystems."/data" =
      { device = "/dev/disk/by-label/data";
        fsType = "btrfs";  
        options = [
          "defaults"            
          "nofail"
          "compress=zstd"
          "space_cache=v2"
          "noatime"
          "commit=120"
        ];
      };

    fileSystems."/boot" =
      { device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

    swapDevices =
      [ { device = "/dev/disk/by-label/swap"; }
      ];
}

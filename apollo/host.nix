{ config, pkgs, lib, modulesPath, inputs, ... }:
let
    nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '';
in {
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  programs.fish.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.simon = {
    description = "Simon Kämpe";
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "wireshark" "lp" "networkmanager" "input" "audio" "libvirtd" "adbusers" ];
    initialPassword = "changethis";
    shell = pkgs.fish;
  };

  networking = {
    hostName = "apollo";
    networkmanager.enable = true;
    useDHCP = lib.mkDefault true;
  };

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "weekly";
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    bluetooth.enable = true;

    nvidia = {
      powerManagement.enable = true;
      modesetting.enable = true;
      open = false;

      prime.offload.enable = true;
      #prime.sync.enable = true;
      prime = {
        # Bus ID of the Intel GPU.
        intelBusId = lib.mkDefault "PCI:0:2:0";
        # Bus ID of the NVIDIA GPU.
        nvidiaBusId = lib.mkDefault "PCI:1:0:0";
      };
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };

  boot = {
    consoleLogLevel = 3;
    
    kernelPackages = lib.mkForce pkgs.linuxPackages;

    supportedFilesystems = [ "ntfs" "nfs" ];

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;

    kernel.sysctl = { "net.ipv4.ip_local_port_range" = "49152 60999"; };
    
    initrd = {
      availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
    };

    blacklistedKernelModules = [ "nouveau" ];
    kernelParams = [ "psmouse.synaptics_intertouch=0" ];

    extraModulePackages = with config.boot.kernelPackages;
      [ v4l2loopback.out ];

    extraModprobeConfig = ''
      # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
      # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
      # https://github.com/umlaeute/v4l2loopback
      options v4l2loopback card_label="Virtual Camera"

      # Fix nvidia crash on resume
      options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_TemporaryFilePath=/var/tmp

      # Better powersaving for nvidia (https://www.reddit.com/r/NixOS/comments/l2ab4i/nvidia_prime_offload_on_dell_xps_7590/)
      options nvidia "NVreg_DynamicPowerManagement=0x02"
    '';
  };

  ## Hardware configuration
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
    { device = "/dev/disk/by-label/Data";
      fsType = "auto";
      options = [ "defaults" "nofail" "user" "rw" "utf8" "auto" "uid=1000" "gid=1000" "umask=022" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/9052965d-f010-4606-a837-b52676963706"; }
    ];

  environment.systemPackages = [
    nvidia-offload
    pkgs.libcamera
    pkgs.libinput
  ];

  services.hardware.bolt.enable = true;
  services.udev.extraRules = ''
    # Always authorize thunderbolt connections when they are plugged in.
    # This is to make sure the USB hub of Thunderbolt is working.
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{authorized}=="0", ATTR{authorized}="1"

    # See https://www.reddit.com/r/NixOS/comments/l2ab4i/nvidia_prime_offload_on_dell_xps_7590/

    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"

    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{remove}="1"

    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"

    # Enable runtime PM for NVIDIA VGA/3D controller devices on driver bind
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="auto"
    ACTION=="bind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="auto"

    # Disable runtime PM for NVIDIA VGA/3D controller devices on driver unbind
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030000", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="unbind", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x030200", TEST=="power/control", ATTR{power/control}="on"
  '';

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
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  # Comment this out until you figure out
  # services.wireplumber.configPackages instead
  #environment.etc = {
  #  "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text =
  #  ''
  #    bluez_monitor.properties = {
  #      ["bluez5.enable-sbc-xq"] = true,
  #      ["bluez5.enable-msbc"] = true,
  #      ["bluez5.enable-hw-volume"] = true,
  #      ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
  #    }
  #  '';
  #};

  ##############
  # Video
  ##############
  services.xserver.videoDrivers = [ "nvidia" ];
}


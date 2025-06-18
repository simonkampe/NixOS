{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ./hardware-configuration.nix

    ./modules/kde.nix
    #./modules/ai.nix
    ./modules/locale.nix
    ./modules/nix.nix
    ./modules/yubikey.nix
    ./modules/zsa.nix
  ];

  users = {
    mutableUsers = true;

    users.simon = {
      description = "Simon Kämpe";
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "lp" "networkmanager" "libvirtd" "plugdev" "kvm" "adbusers" "wireshark" "dialout" ];
      initialPassword = "changethis";
      shell = pkgs.fish;
    };
  };

  networking = {
    hostName = "starscream";
    networkmanager.enable = true;
    # nftables = {
    #   enable = true;
    #   tables = {
    #     # Make tailscale net accessible even when mullvad is enabled
    #     mullvad_tailscale = {
    #       content = ''
    #         chain output {
    #           type route hook output priority -100; policy accept;
    #           ip daddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
    #         }

    #         chain input {
    #           type filter hook input priority -100; policy accept;
    #           ip saddr 100.64.0.0/10 ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
    #         }
    #       '';
    #       family = "inet";
    #     };
    #   };
    # };
    #extraHosts = ''
    #  192.168.101.151 adaptio.local
    #'';
  };

  programs = {
    adb.enable = true;
    fish.enable = true;
    
    gamemode.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
      localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
    };

    tosibox-key = {
      enable = true;
      package = pkgs.tosibox;
    };

    virt-manager.enable = true;

    wireshark = {
      enable = true;
      dumpcap.enable = true;
      usbmon.enable = true;
    };
  };

  virtualisation = {
    docker.enable = true;
    spiceUSBRedirection.enable = true;

    #vmware.host = {
    #  enable = true;
    #  package = pkgs.vmware-workstation;
    #};

    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  security.polkit.enable = true;

  powerManagement.enable = true;

  # Temporary work around for USB dead on resume:
  #
  powerManagement.resumeCommands = ''
    mount -t debugfs none /sys/kernel/debug
    echo 'module xhci_hcd =p' >/sys/kernel/debug/dynamic_debug/control
    echo 'module usbcore =p' >/sys/kernel/debug/dynamic_debug/control
    #echo 'func xhci_handle_cmd_stop_ep +p' >/proc/dynamic_debug/control
  '';

  services = {
    #flatpak.enable = true;
    fwupd.enable = true;
    pcscd.enable = true;
    upower.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = false;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    # Anti-virus
    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    mullvad-vpn = {
      enable = true;
      package = pkgs.mullvad-vpn;
    };

    nextjs-ollama-llm-ui = {
      enable = true;
    };

    ollama = {
      enable = true;
      acceleration = "cuda";
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        # Epson
        epson-escpr2
        epsonscan2
      ];
    };

    resolved.enable = true;

    sunshine = {
      enable = true;
      autoStart = false;
      openFirewall = true;
      capSysAdmin = true;
    };

    tailscale.enable = true;

    thermald = {
      enable = true;
      ignoreCpuidCheck = true;
    };

    udev.extraRules = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="35ca", MODE="0664", GROUP="users"
    '';
  };

  # Set systemd affinity to the E-cores
  #systemd.extraConfig = ''
  #  CPUAffinity=12 13 14 15 16 17 18 19 20 21
  #'';

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    noto-fonts
  ];

  environment = {
    sessionVariables.NIXOS_OZONE_WL = "1";

    pathsToLink = [ "/share/nix-direnv" ];

    systemPackages = with pkgs; [
      # Browsers
      brave
      chromium

      # Office
      onlyoffice-bin_latest
      synology-drive-client
      simple-scan

      # Graphics
      inkscape
      #aseprite

      # Media
      spotify
      vlc

      # Social
      discord

      # Note taking
      obsidian

      # Anti-virus
      clamav

      # IDEs
      jetbrains.clion
      jetbrains.rust-rover
      jetbrains.pycharm-professional
      jetbrains.webstorm

      android-studio

      (vscodium.fhsWithPackages (ps: with ps; [
        nodejs
        stdenv.cc.cc.lib
      ]))

      zed-editor

      # Dev tools
      git
      mercurial
      jujutsu
      qemu
      sqlite
      azure-cli

      # Tooling
      wireshark
      teamviewer
      ghidra

      # System utilities

      ## Network
      curl
      samba
      nmap
      wget
      tunctl
      bridge-utils

      ## Hardware
      glxinfo
      pciutils
      usbutils
      inxi
      nvtopPackages.full

      ## Utilities
      tpm2-tss
      libsecret
      killall
      screen
      silver-searcher
      unrar
      unzip
      p7zip
      jq
      fontconfig
      pavucontrol
      parted
      e2fsprogs

      # Entertainment
      (prismlauncher.override { # See: https://wiki.nixos.org/wiki/Prism_Launcher
      #  # Add binary required by some mod
        additionalPrograms = [ ffmpeg ];

      #  # Change Java runtimes available to Prism Launcher
        jdks = [
      #    #graalvm-ce
      #    #zulu8
      #    #zulu17
          zulu
        ];
      })
    ];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}

{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ./hardware-configuration.nix

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
      extraGroups = [ "wheel" "docker" "lp" "networkmanager" "libvirtd" "plugdev" ];
      initialPassword = "changethis";
      shell = pkgs.fish;
    };
  };

  networking = {
    hostName = "starscream";
    networkmanager.enable = true;
  };

  programs = {
    virt-manager.enable = true;
    fish.enable = true;
    seahorse.enable = true;
    
    evolution = {
      enable = true;
      plugins = [ pkgs.evolution-ews ];
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    tosibox-key = {
      enable = true;
      package = pkgs.tosibox;
    };
  } // { # Hyprland
    uwsm.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };

  virtualisation = {
    docker.enable = true;
    spiceUSBRedirection.enable = true;

    vmware.host = {
      enable = true;
      package = pkgs.vmware-workstation;
    };

    libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
  };

  security.polkit.enable = true;

  powerManagement.enable = true;

  services = {
    tailscale.enable = true;
    #flatpak.enable = true;
    fwupd.enable = true;
    pcscd.enable = true;
    thermald.enable = true;
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

    gnome = {
      evolution-data-server.enable = true;
      gnome-keyring.enable = true;
    };

    gvfs = {
      enable = true;
    };

    logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
      lidSwitchDocked = "ignore";
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        # Epson
        epson-escpr2
        epsonscan2
      ];
    };

    tlp = {
      enable = true;
      settings = {
      };
    };
  };

  # Set systemd affinity to the E-cores
  systemd.extraConfig = ''
    CPUAffinity=12 13 14 15 16 17 18 19 20 21
  '';

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

      # Graphics
      inkscape
      #aseprite

      # Media
      spotify
      vlc

      # Social
      discord

      # Note taking
      #obsidian

      # Anti-virus
      clamav

      # IDEs
      jetbrains.clion
      jetbrains.rust-rover

      (vscodium.fhsWithPackages (ps: with ps; [
        nodejs
        stdenv.cc.cc.lib
      ]))

      # Dev tools
      git
      qemu
      apax
      sqlite

      # Tooling
      wireshark
      teamviewer

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

      ## Utilities
      tpm2-tss
      killall
      screen
      silver-searcher
      unrar
      unzip
      p7zip
      fontconfig
      pavucontrol
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

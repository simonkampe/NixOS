{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ./hardware-configuration.nix

    #./modules/ai.nix
    ./modules/hyprland.nix
    ./modules/locale.nix
    ./modules/nix.nix
    #./modules/yubikey.nix
  ];

  users = {
    mutableUsers = true;

    users.simon = {
      description = "Simon Kämpe";
      isNormalUser = true;
      extraGroups = [ "wheel" "docker" "lp" "networkmanager" "input" "audio" "libvirtd" ];
      initialPassword = "changethis";
      shell = pkgs.fish;
    };
  };

  networking = {
    hostName = "starscream";
    networkmanager.enable = true;
  };

  programs = {
    tosibox-key.enable = true;
    virt-manager.enable = true;
    fish.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  virtualisation = {
    docker.enable = true;

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

  services = {
    tailscale.enable = true;
    #flatpak.enable = true;
    fwupd.enable = true;
    pcscd.enable = true;
    timesyncd.enable = lib.mkDefault true;

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

    printing = {
      enable = true;
      drivers = with pkgs; [
        # Brother
        brlaser

        # Canon
        canon-cups-ufr2
        cnijfilter2
        cnijfilter_4_00
        cnijfilter_2_80

        # HP
        hplip

        # Epson
        epson-escpr2
        epsonscan2
      ];
    };
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    ibm-plex
    comfortaa
    noto-fonts
    material-design-icons
  ];

  environment = {
    pathsToLink = [ "/share/nix-direnv" ];

    systemPackages = with pkgs; [
      # Browsers
      brave
      chromium

      # Office
      onlyoffice-bin_latest

      # Graphics
      inkscape
      aseprite

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
      jetbrains.pycharm-professional
      jetbrains.webstorm
      jetbrains.rider
      jetbrains.rust-rover
      jetbrains.idea-ultimate
      jetbrains.datagrip
      bluej

      (vscodium.fhsWithPackages (ps: with ps; [
        nodejs
        stdenv.cc.cc.lib
        dotnetCorePackages.sdk_6_0
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
      killall
      screen
      silver-searcher
      unrar
      unzip
      p7zip
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
{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ./hardware-configuration.nix

    ./modules/kde.nix
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
    hostName = "optimus";
    networkmanager.enable = true;
  };

  programs = {
    fish.enable = true;
    seahorse.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      localNetworkGameTransfers.openFirewall = true;
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = true;
    };
  };

  security.polkit.enable = true;

  services = {
    tailscale.enable = true;
    #flatpak.enable = true;
    fwupd.enable = true;
    pcscd.enable = true;

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

    printing = {
      enable = true;
      drivers = with pkgs; [
        # Epson
        epson-escpr2
        epsonscan2
      ];
    };
  };

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

      # Office
      onlyoffice-bin_latest

      # Media
      spotify
      vlc

      # Gaming
      protonup-ng

      # Social
      discord

      # Anti-virus
      clamav

      # Dev tools
      git

      # System utilities

      ## Network
      curl
      samba
      nmap
      wget

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
  system.stateVersion = "23.05"; # Did you read the comment?
}
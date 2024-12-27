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
    hostName = "optimus";
    networkmanager.enable = true;
  };

  programs = {
    fish.enable = true;

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

      # IDEs
      jetbrains.clion
      jetbrains.rust-rover
      jetbrains.idea-ultimate

      # Dev tools
      git

      # System utilities

      ## Network
      curl
      wget

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
  system.stateVersion = "23.05"; # Did you read the comment?
}
{ inputs, config, lib, pkgs, ... } :
{
  console.keyMap = "sv-latin1";

  time = {
    timeZone = "Europe/Stockholm";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_MEASUREMENT = "sv_SE.UTF-8";
      LC_TIME = "sv_SE.UTF-8";
      LC_NUMERIC = "sv_SE.UTF-8";
    };
  };

  users = {
    mutableUsers = true;

    users.simon = {
      description = "Simon Kämpe";
      isNormalUser = true;
      extraGroups = [ "wheel" "lp" "networkmanager" "libvirtd" "plugdev" ];
      initialPassword = "changethis";
      shell = pkgs.fish;
    };
  };

  powerManagement.enable = true;

  security = {
    polkit.enable = true;
  };

  networking.networkmanager.enable = true;

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.hack
    noto-fonts
  ];

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        domain = true;
        hinfo = true;
        userServices = true;
        workstation = true;
      };
    };

    clamav = {
      daemon.enable = true;
      updater.enable = true;
    };

    fwupd.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
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

    tailscale.enable = true;

    timesyncd.enable = true;
  };

  programs = {
    fish.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    # Antivirus
    clamav

    # Dev
    mercurial
    git
    devbox

    # Networking
    curl
    nmap
    samba
    wget

    # Hardware
    pciutils
    usbutils
    inxi

    # Archives
    p7zip
    unrar
    unzip

    # Other
    bridge-utils
    e2fsprogs
    fontconfig
    jq
    killall
    screen
    libsecret
    parted
    tpm2-tss
    tunctl
  ];

  nix =
  let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      flake-registry = "";
      nix-path = config.nix.nixPath;
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
    };

    channel.enable = false;

    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
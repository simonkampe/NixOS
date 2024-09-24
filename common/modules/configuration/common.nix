{ pkgs, ... }:
{
  time = {
    timeZone = "Europe/Stockholm";
    hardwareClockInLocalTime = true;
  };

  services.timesyncd.enable = true;

  console.keyMap = "sv-latin1";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_MEASUREMENT = "sv_SE.UTF-8";
      LC_NUMERIC = "sv_SE.UTF-8";
      LC_TIME = "sv_SE.UTF-8";
    };
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ibm-plex
    comfortaa
    noto-fonts
    material-design-icons
  ];

  # nix options for derivations to persist garbage collection
  nix = {
    settings.experimental-features = [ "nix-command" "flakes" ];
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      sandbox = relaxed
    '';
  };

  environment.pathsToLink = [
    "/share/nix-direnv"
  ];

  # Common utilities
  environment.systemPackages = with pkgs; [
    # Network/web
    curl
    nmap
    wget
    sqlite
    tunctl
    bridge-utils

    # Hardware
    glxinfo
    pciutils
    usbutils
    inxi

    # Utilities
    htop
    killall
    screen
    silver-searcher
    unrar
    unzip
    p7zip
    xcp
    git

    # Nix lang
    nil
    nixfmt-classic

    # Wine
    bottles
    wineWowPackages.waylandFull
    winetricks
  ];
}

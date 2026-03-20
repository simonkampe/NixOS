{ inputs, lib, config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Browsers
    brave

    # Office
    onlyoffice-desktopeditors
    obsidian
    zed-editor

    # Media
    spotify
    vlc

    # Social
    discord
    slack
  ];
}
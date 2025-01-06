{ pkgs, ... }:

{
  home.packages = with pkgs; [
    blueman
    foot
    ghostty
    networkmanagerapplet
    swww
    waypaper
    wofi
    xfce.thunar
    xfce.thunar-volman
  ];

  xdg = {
    enable = true;
    configFile."ghostty" = {
      source = ./config/ghostty;
      recursive = true;
    };
    configFile."hypr" = {
      source = ./config/hypr;
      recursive = true;
    };
    configFile."wofi" = {
      source = ./config/wofi;
      recursive = true;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.posy-cursors;
    name = "Posy_Cursor";
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      package = pkgs.qogir-theme;
      name = "Qogir-Dark";
    };

    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir-dark";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };

  qt = {
    enable = true;
    style = {
      package = pkgs.qogir-kde;
      name = "Qogir-dark";
    };
  };
}

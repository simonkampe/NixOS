{ pkgs, ... }:

{
  home.packages = with pkgs; [
    blueman
    foot
    grim
    hypridle
    hyprlock
    hyprpaper
    networkmanagerapplet
    swaynotificationcenter
    waybar
    wofi
    workstyle
    xfce.thunar
    xfce.thunar-volman
  ];

  xdg = {
    enable = true;
    configFile."foot" = {
      source = ./config/foot;
      recursive = true;
    };
    configFile."hypr" = {
      source = ./config/hypr;
      recursive = true;
    };
    configFile."swaync" = {
      source = ./config/swaync;
      recursive = true;
    };
    configFile."waybar" = {
      source = ./config/waybar;
      recursive = true;
    };
    configFile."wofi" = {
      source = ./config/wofi;
      recursive = true;
    };
    configFile."workstyle" = {
      source = ./config/workstyle;
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
      package = pkgs.orchis-theme;
      name = "Orchis-Dark";
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

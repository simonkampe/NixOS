{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.home.hyprland;
in {
  options.modules.home.hyprland = {
    enable = mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {

    wayland.windowManager.hyprland = {
      enable = true;
      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;

      systemd.variables = ["--all"];

      settings = {
        "$mod" = "SUPER";
      };

      plugins = [];
    };

    home = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      pointerCursor = {
        gtk.enable = true;
        # x11.enable = true;
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 16;
      };
    };

    programs = {
      # Terminal
      ghostty.enable = true;
      kitty.enable = true; # Required for standard config

      # Bar
      waybar.enable = true;
    };

    home.packages = with pkgs; [
      # Bluetooth manager
      bluetui

      # Network manager
      impala

      # Notification daemon
      mako

      # OSD
      swayosd

      # Launcher
      elephant
      walker

      # Sound
      wiremix

      # Other
      gum
    ]
    # Utility scripts
    ++ import ./scripts/default.nix pkgs;

    gtk = {
      enable = true;

      theme = {
        package = pkgs.flat-remix-gtk;
        name = "Flat-Remix-GTK-Grey-Darkest";
      };

      iconTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
      };

      font = {
        name = "Sans";
        size = 11;
      };
    };

    xdg = {
      enable = true;
      configFile = import ./config/default.nix { inherit lib; };
      terminal-exec = {
        enable = true;
        settings = {
          default = [
            "com.mitchellh.ghostty.desktop"
          ];
        };
      };
    };
  };
}

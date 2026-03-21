{ config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.system.desktop.hyprland;
in {
  options.modules.system.desktop.hyprland = {
    enable = mkEnableOption "hyprland";
  };

  config = lib.mkIf cfg.enable {
    services = {
      hypridle.enable = true;

      power-profiles-daemon.enable = true;
    };

    #security.polkit.package = pkgs.hyprpolkitagent;

    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      NVD_BACKEND = "direct";

      # Force wayland on stuff
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      NIXOS_OZONE_WL = "1";
      GDK_BACKEND = "wayland,x11,*";
      QT_QPA_PLATFORM = "wayland;xcb";
      QT_STYLE_OVERRIDE = "kvantum";
      SDL_VIDEODRIVER = "wayland,x11";
      MOZ_ENABLE_WAYLAND = "1";
      OZONE_PLATFORM = "wayland";
      XDG_SESSION_TYPE = "wayland";

      # Better support for screen sharing
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
    };

    # Core
    programs = {
      hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = true;
      };

      hyprlock.enable = true;

      uwsm.enable = true;

      seahorse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hyprsunset
      nautilus
      pulseaudio
    ];
  };
}

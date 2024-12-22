{ config, pkgs, ... }:

{
  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
    };

    waybar.enable = true;

    uwsm = {
      enable = true;
      waylandCompositors."hyprland" = {
        binPath = "/run/current-system/sw/bin/Hyprland";
        prettyName = "Hyprland";
      };
    };
  };

  services = {
    xserver.enable = false;
  };

  fonts.packages = with pkgs; [
    noto-fonts
  ];

  environment = {
    # Hint Electron apps to use wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      foot
      hyprpanel
      wofi
      xfce.thunar
      xfce.thunar-volman
    ];
  };
}
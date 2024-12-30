{ config, pkgs, ... }:

{
  programs = {
    uwsm.enable = true;

    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
  };

  services.upower.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.hack
  ];

  environment = {
    # Hint Electron apps to use wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      fontconfig
      pavucontrol
    ];
  };
}

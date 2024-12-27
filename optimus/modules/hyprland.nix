{ config, pkgs, ... }:

{
  programs = {
    hyprland = {
      enable = true;
    };
  };

  services = {
    xserver.enable = false;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme ";
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    nerd-fonts.hack
  ];

  environment = {
    # Hint Electron apps to use wayland
    sessionVariables.NIXOS_OZONE_WL = "1";

    systemPackages = with pkgs; [
      fontconfig
      sddm-astronaut
      pavucontrol
      python3Full
    ];
  };
}
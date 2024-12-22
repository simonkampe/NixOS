{ config, pkgs, ... }:
{
  # Link stuff currently unsupported by home-manager
  xdg = {
    enable = true;
    configFile."cargo" = {
      source = config/cargo;
      recursive = true;
    };
  };

  # Extra utilities
  home.packages = with pkgs; [
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}


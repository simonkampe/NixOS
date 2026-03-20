{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ../../modules/system/default.nix
  ];

  config.modules.system = {
    desktop.kde.enable = true;
    hardware.uhk.enable = true;
    hardware.yubikey = { enable = true; withPam = false; };
    hardware.zsa.enable = true;
    programs.steam.enable = true;
  };

  config.environment.systemPackages = with pkgs; [
  ];

  # No touchie
  config.system.stateVersion = "23.05";
}
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    uhk-agent
  ];

  services.udev.packages = with pkgs; [
    uhk-udev-rules
  ];
}

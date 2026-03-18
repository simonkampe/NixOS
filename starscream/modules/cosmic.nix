{ pkgs, lib, ... }:

{
  services = {
    xserver.enable = true;
    displayManager.cosmic-greeter = {
      enable = true;
    };
  };

  services.desktopManager.cosmic.enable = true;
  services.system76-scheduler.enable = true;

  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;

  environment.sessionVariables = {
  };

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  programs.partition-manager.enable = true;
}

{ inputs, config, pkgs, lib, ... }:
with lib;
let
  cfg = config.modules.system.desktop.kde;
in {
  options.modules.system.desktop.kde = {
    enable = mkEnableOption "kde";
  };

  config = lib.mkIf cfg.enable {
    services = {
      xserver.enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true; # Run SDDM in wayland
      };
      desktopManager.plasma6.enable = true;
    };

    programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;

    environment.sessionVariables = {
      QML_XHR_ALLOW_FILE_READ="1"; # Fix warning flooding journalctl
    };

    services.power-profiles-daemon.enable = true;

    environment.systemPackages = with pkgs; [
      wl-clipboard
      kdePackages.powerdevil
      kdePackages.filelight
      kdePackages.kauth
      kdePackages.ark
      kdePackages.kalk
      kdePackages.kate
      kdePackages.sddm-kcm
      kdePackages.plasma-thunderbolt
      kdePackages.kmail
      kdePackages.kmail-account-wizard
      kdePackages.kmailtransport
      kdePackages.skanpage
      kdePackages.kdepim-addons
      kdePackages.kdepim-runtime
    ];

    programs.partition-manager.enable = true;
  };
}

{ pkgs, lib, ... }:

{
  services = {
    xserver.enable = true;
    displayManager.sddm = {
      enable = true;
      wayland.enable = true; # Run SDDM in wayland
    };
  };

  services.desktopManager.plasma6.enable = true;

  programs.gnupg.agent.pinentryPackage = lib.mkForce pkgs.pinentry-qt;

  environment.sessionVariables = {
    QML_XHR_ALLOW_FILE_READ="1"; # Fix warning flooding journalctl
  };

  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    nordic
    kdePackages.powerdevil
    kdePackages.kio-gdrive
    kdePackages.kaccounts-providers
    kdePackages.kaccounts-integration
    kdePackages.filelight
    kdePackages.signond
    kdePackages.kauth
    kdePackages.kontact
    kdePackages.kontactinterface
    kdePackages.ark
    kdePackages.kalk
    kdePackages.kate
    kdePackages.merkuro
    kdePackages.sddm-kcm
    kdePackages.plasma-thunderbolt
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.kmailtransport
    kdePackages.skanpage
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.akonadi
    kdePackages.akonadi-mime
    kdePackages.akonadi-notes
    kdePackages.akonadi-search
    kdePackages.akonadi-contacts
    kdePackages.akonadi-calendar
    kdePackages.akonadi-calendar-tools
    kdePackages.akonadi-import-wizard
  ];

  programs.partition-manager.enable = true;
}

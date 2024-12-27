{ config, pkgs, ... }:

{
  services = {
    udev.packages = [
      pkgs.yubikey-personalization
    ];
  };

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  #security.pam.services = {
  #  login.u2fAuth = true;
  #  sudo.u2fAuth = true;
  #};

  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager
    yubico-piv-tool
    yubikey-personalization-gui
    age-plugin-yubikey
    pamtester
  ];

  # Lock screen when a key is removed
  services.udev.extraRules = ''
    ACTION=="remove",\
    ENV{ID_BUS}=="usb",\
    ENV{ID_MODEL_ID}=="0407",\
    ENV{ID_VENDOR_ID}=="1050",\
    ENV{ID_VENDOR}=="Yubico",\
    RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  systemd.user.scokets."piv-agent" = {
    enable = true;
    description = "piv-agent socket activation";
    listenStreams = [
      "%t/piv-agent/ssh.socket"
      "%t/gnupg/S.gpg-agent"
    ];
  };

  systemd.user.services."piv-agent" = {
    enable = true;
    description = "piv-agent service";
    serviceConfig = {
      ExecStart = "piv-agent serve --agent-types=ssh=1;gpg=1";
    };
  };
}
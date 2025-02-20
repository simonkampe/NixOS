{ config, pkgs, ... }:

{
  services = {
    pcscd.enable = true;

    udev.packages = [
      pkgs.yubikey-personalization
    ];
  };

  security.pam.yubico = {
    enable = true;
    debug = false;
    mode = "challenge-response";
    control = "required";
    id = [ "31016249" "32202734" ];
  };

  environment.systemPackages = with pkgs; [
    yubioath-flutter
    yubikey-manager
    yubico-pam
    yubikey-personalization-gui
    age-plugin-yubikey
    yubikey-touch-detector
  ];

  programs.yubikey-touch-detector = {
    enable = true;
    libnotify = true;
  };
}

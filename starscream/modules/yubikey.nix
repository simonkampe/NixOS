{ config, pkgs, ... }:

{
  services.udev.packages = [
    pkgs.yubikey-personalization
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  security.pam.yubico = {
    enable = true;
    control = "required";
    mode = "challenge-response";
    id = [ "12345678" ];
  };

  environment.systemPackages = [
    pkgs.yubioath-flutter
  ];
}
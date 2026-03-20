{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.hardware.yubikey;
in {
  options.modules.system.hardware.yubikey = {
    enable = mkEnableOption "yubikey";
    withPam = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services = {
        pcscd.enable = true;

        udev.packages = [
          pkgs.yubikey-personalization
        ];
      };

      environment.systemPackages = with pkgs; [
        yubioath-flutter
        yubikey-manager
        yubico-pam
        age-plugin-yubikey
      ];
    }

    (mkIf cfg.withPam {
      security.pam.yubico = {
        enable = true;
        debug = false;
        mode = "challenge-response";
        control = "required";
        id = [ "31016249" "32202734" ];
      };
    })
  ]);
}

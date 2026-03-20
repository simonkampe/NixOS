{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.dev.qemu;
in {
  options.modules.system.dev.qemu = {
    enable = mkEnableOption "qemu";
  };

  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    virtualisation = {
      spiceUSBRedirection.enable = true;

      libvirtd = {
        enable = true;
        qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
      };
    };

    environment.systemPackages = with pkgs; [
      qemu
    ];
  };
}

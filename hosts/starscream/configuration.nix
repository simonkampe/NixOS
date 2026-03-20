{ inputs, config, lib, pkgs, ... } :

{
  imports = [
    ../../modules/system/default.nix
  ];

  config.modules.system = {
    desktop.kde.enable = true;
    dev.docker = { enable = true; user = "simon"; };
    dev.qemu.enable = true;
    hardware.buspirate.enable = true;
    hardware.uhk.enable = true;
    hardware.yubikey.enable = true;
    hardware.zsa.enable = true;
    programs.wireshark = { enable = true; user = "simon"; };
  };

  # Temporary work around for USB dead on resume:
  #powerManagement.resumeCommands = ''
  #  mount -t debugfs none /sys/kernel/debug
  #  echo 'module xhci_hcd =p' >/sys/kernel/debug/dynamic_debug/control
  #  echo 'module usbcore =p' >/sys/kernel/debug/dynamic_debug/control
  #'';

  # Disable avahi publish for this machine
  config.services.avahi.publish.enable = lib.mkForce false;

  config.environment.systemPackages = with pkgs; [
    # Browsers
    chromium

    # Office
    teamviewer

    # IDEs
    jetbrains.clion
    jetbrains.rust-rover
    jetbrains.pycharm
    jetbrains.webstorm
    jetbrains.idea
    vscode.fhs

    # Tools
    arduino
    bruno
    minicom
    sqlite
    tio

    # Work stuff
    inputs.tosibox-key.packages.${pkgs.system}.default
  ];

  # No touchie
  config.system.stateVersion = "24.11";
}
{ inputs, pkgs, config, ... }:

{
  imports = [
    ./desktop/kde.nix
    ./dev/docker.nix
    ./dev/qemu.nix
    ./hardware/buspirate.nix
    ./hardware/uhk.nix
    ./hardware/yubikey.nix
    ./hardware/zsa.nix
    ./programs/steam.nix
    ./programs/wireshark.nix
  ];
}
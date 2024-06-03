{ config, lib, pkgs, modulesPath, ... }:
let
  configTxt = pkgs.writeText "config.txt" ''
  '';
in
{
  imports = [ (modulesPath + "/installer/sd-card/sd-image-aarch64.nix") ];

  sdImage = {
    compressImage = false;
    imageBaseName = config.networking.hostName;
    populateFirmwareCommands = ''
      #cp ${configTxt} firmware/config.txt
    '';
    populateRootCommands = ''
    '';
  };
}
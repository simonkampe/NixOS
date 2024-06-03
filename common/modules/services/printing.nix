{ config, pkgs, ... }:
{
  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.canon-cups-ufr2 ];
    };
  };
}

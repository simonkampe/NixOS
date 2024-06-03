{ config, pkgs, ... }:
{
  virtualisation.vmware.host = {
    enable = true;
    package = pkgs.vmware-workstation;
  };
}

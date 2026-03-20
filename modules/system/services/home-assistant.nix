{ config, pkgs, ... }:
{
  virtualisation.oci-containers = {
    backend = "podman";

    containers.homeassistant = {
      volumes = [ "home-assistant:/config" ];
    
      environment.TZ = "Europe/Stockholm";
    
      image = "ghcr.io/home-assistant/home-assistant:stable";
    
      extraOptions = [
        "--network=host"
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 8123 ];
  };
}

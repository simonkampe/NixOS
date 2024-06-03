{ pkgs, config, ...}:
{
  
  services.nextcloud = {                
    enable = true;
    package = pkgs.nextcloud28;
    extraApps = {
      inherit (config.services.nextcloud.package.packages.apps) contacts calendar tasks mail;
    };
    extraAppsEnable = true;
  };
  
}

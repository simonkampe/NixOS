{ config, pkgs, ... }:

{
  xdg.desktopEntries = {
    ka-office = {
      name = "KA Office";
      genericName = "Web Browser";
      exec = ''kauto-office'';
      terminal = false;
      icon = "chromium";
      categories = [ "Application" "Office" ];
    };

    esab-office = {
      name = "ESAB Office";
      genericName = "Web Browser";
      exec = ''esab-office'';
      terminal = false;
      icon = "chromium";
      categories = [ "Application" "Office" ];
    };
  };
}

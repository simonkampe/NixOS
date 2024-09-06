{ config, pkgs, ... }:
{
  services = {
    printing = {
      enable = true;
      drivers = with pkgs; [
        # Brother
        brlaser

        # Canon
        canon-cups-ufr2
        cnijfilter2
        cnijfilter_4_00
        cnijfilter_2_80
        
        # HP
        hplip

        # Epson
        epson-escpr2
        epsonscan2
      ];
    };
  };
}

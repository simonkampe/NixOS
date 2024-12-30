{ config, ... }:

{
  time = {
    timeZone = "Europe/Stockholm";
    hardwareClockInLocalTime = true;
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [ "en_US.UTF-8/UTF-8" "sv_SE.UTF-8/UTF-8" ];
    extraLocaleSettings = {
      LC_MEASUREMENT = "sv_SE.UTF-8";
      LC_TIME = "sv_SE.UTF-8";
    };
  };
}
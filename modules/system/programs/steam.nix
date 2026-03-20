{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.programs.steam;
in {
  options.modules.system.programs.steam = {
    enable = mkEnableOption "steam";

    user = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = false; # Open ports in the firewall for Steam Remote Play
      localNetworkGameTransfers.openFirewall = true;
      dedicatedServer.openFirewall = false; # Open ports in the firewall for Source Dedicated Server
      gamescopeSession.enable = false;
    };

    environment.systemPackages = with pkgs; [
      protonup-ng
    ];
  };
}
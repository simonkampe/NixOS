{ inputs, lib, config, pkgs, ... }:
with lib;
let
  cfg = config.modules.system.programs.ghidra;
in {
  options.modules.system.programs.ghidra = {
    enable = mkEnableOption "ghidra";

    user = mkOption {
      type = types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghidra = {
      enable = true;
      gdb = true;
      package = (pkgs.ghidra.withExtensions (p: with p; [
        findcrypt
        lightkeeper
        ret-sync
      ]));
    };
  };
}
{ inputs, config, lib, pkgs, ... }:
with lib;
let
  cfg = config.modules.home.jj;
in {
  options.modules.home.jj = {
    enable = mkEnableOption "jj";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      difftastic
    ];

    programs.jujutsu = {
      enable = true;

      settings = {
        user = {
          email = "simon@simraconsulting.se";
          name = "Simon Kämpe";
        };

        ui = {
          color = "auto";
          default-command = ["log"];
          diff-formatter = ["difft" "--color=always" "$left" "$right"];
        };

        templates-aliases = {
          default_commit_description = "
          feat|fix|chore: <title>

          Issues: NONE
          ";
        };
      };
    };
  };
}
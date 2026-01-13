{ config, pkgs, ... }:

{
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
}

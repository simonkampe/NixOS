{ config, lib, inputs, pkgs, ... }:

{
    imports = [
      ../../modules/home/default.nix
      inputs.agenix.homeManagerModules.age
    ];

    config = {
      modules.home = {
        git.enable = true;
        gpg.enable = true;
        helix.enable = true;
        hyprland.enable = true;
        jj.enable = true;
        shell = {
          enable = true;
          prependInit = ''
            set -gx APAX_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.apax-token.path})
            set -gx CODEBERG_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.codeberg-token.path})
            set -gx GITHUB_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.github-token.path})
            set -gx GITLAB_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.gitlab-token.path} | sed -E 's|.*:(.*)|\1|')
          '';
        };
      };

      home.packages = with pkgs; [
        inputs.agenix.packages.${pkgs.system}.default
      ];

      xdg = {
        enable = true;
        configFile = {
          "git" = {
            source = ./config/git;
            recursive = true;
          };
          "cargo" = {
            source = ./config/cargo;
            recursive = true;
          };
        };
      };

      age.secrets = {
        apax-token.file = /home/simon/.secrets/apax-token.age;
        codeberg-token.file = /home/simon/.secrets/codeberg-token.age;
        github-token.file = /home/simon/.secrets/github-token.age;
        gitlab-token.file = /home/simon/.secrets/gitlab-token.age;
      };

      nix.extraOptions = ''
        !include ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.codeberg-token.path}
        !include ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.github-token.path}
        !include ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.gitlab-token.path}
      '';

      home.stateVersion = "24.11";
    };
}

{ inputs, config, pkgs, ... } :

{
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  imports = [
    inputs.agenix.homeManagerModules.age

    ../../home/git.nix
    ../../home/gpg.nix
    ../../home/hyprland.nix
    ../../home/hyprpanel.nix
    ../../home/helix.nix

    (import ../../home/shell.nix {
      inherit config pkgs;
      prepend_shell = ''
        set -gx GITHUB_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.github-token.path})
        set -gx GITLAB_TOKEN $(cat ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.gitlab-token.path} | sed -E 's|.*:(.*)|\1|')
      '';
    })
  ];

  home.packages = with pkgs; [
    agenix
  ];

  xdg = {
    enable = true;
    configFile."git" = {
      source = ./config/git;
      recursive = true;
    };
  };

  age.secrets = {
    gitlab-token.file = /home/simon/.secrets/gitlab-token.age;
    github-token.file = /home/simon/.secrets/github-token.age;
  };

  nix.extraOptions = ''
    !include ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.gitlab-token.path}
  '';

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.11";
}

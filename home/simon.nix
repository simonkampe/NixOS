{ config, pkgs, ... }:

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Link stuff currently unsupported by home-manager
  xdg = {
    enable = true;
    configFile."cargo" = {
      source = config/cargo;
      recursive = true;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Extra utilities
  home.packages = with pkgs; [
    # Shell
    any-nix-shell
    nil
    nixd
  ];

  age.secrets = {
    gitlab-token.file = /home/simon/.secrets/gitlab-token.age;
    github-token.file = /home/simon/.secrets/github-token.age;
  };

  nix = {
    package = pkgs.nix;

    settings = {
      sandbox = "relaxed";
      show-trace = true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      !include ${builtins.replaceStrings [ "\${XDG_RUNTIME_DIR}/" ] [ "/run/user/1000/" ] config.age.secrets.gitlab-token.path}
    '';
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
  };
}

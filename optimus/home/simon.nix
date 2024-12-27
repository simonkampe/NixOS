{ agenix, ... } :

{
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  imports = [
    agenix.homeManagerModules.age

    ./hyprland.nix

    ../../home/shell.nix
    ../../home/git.nix
    ../../home/helix.nix
  ];

  age.secrets = {
    #gitlab-token.file = /home/simon/.secrets/gitlab-token.age;
    #github-token.file = /home/simon/.secrets/github-token.age;
  };

  # Link stuff currently not managed by home-manager
  xdg = {
    enable = true;
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";
}
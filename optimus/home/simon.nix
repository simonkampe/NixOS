{ inputs, config, pkgs, ... } :

{
  home.username = "simon";
  home.homeDirectory = "/home/simon";

  imports = [
    inputs.spicetify-nix.homeManagerModules.default

    ../../home/git.nix
    ../../home/hyprland.nix
    ../../home/hyprpanel.nix
    ../../home/helix.nix

    (import ../../home/shell.nix { inherit config pkgs; prepend_shell = ""; })
  ];

  # Link stuff currently not managed by home-manager
  xdg = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in {
    enable = true;

    enabledExtensions = with spicePkgs.extensions; [
      adblock
      #hidePodcasts
      #shuffle # shuffle+ (special characters are sanitized out of extension names)
    ];

    theme = spicePkgs.themes.sleek;
    colorScheme = "nord";
  };

  services.gpg-agent = {
    pinentryPackage = pkgs.pinentry-gnome3;
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

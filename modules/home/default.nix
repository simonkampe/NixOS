{ inputs, pkgs, config, ... }:

{
  imports = [
    ./direnv.nix
    ./git.nix
    ./gpg.nix
    ./helix.nix
    ./jj.nix
    ./shell.nix
  ];
}
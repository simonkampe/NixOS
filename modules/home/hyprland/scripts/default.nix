{ pkgs, ... }:

let
  mkScript = category: name:
    pkgs.writeShellScriptBin "${category}-${name}" (builtins.readFile (./. + "/${category}/${name}"));

  mkScriptsInDir = category:
    let
      dirPath = ./. + "/${category}";
      contents = builtins.readDir dirPath;
      names = builtins.filter (name: contents.${name} == "regular") (builtins.attrNames contents);
    in
      map (mkScript category) names;

  mkAllScripts =
    let
      dirPath = ./.;
      contents = builtins.readDir dirPath;
      categories = builtins.filter (name: contents.${name} == "directory") (builtins.attrNames contents);
    in
      map (mkScriptsInDir) categories;

in with pkgs; lib.flatten [
  # General script dependencies
  brightnessctl
  hyprpicker
  slurp
  upower
  gpu-screen-recorder
  grim

  mkAllScripts
]
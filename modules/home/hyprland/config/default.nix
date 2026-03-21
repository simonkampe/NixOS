{ lib, ... }:

let
  mkConfigAttrs = config:
    {
      name = "${config}";
      value = {
        source = ./. + "/${config}";
        recursive = true;
      };
    };

  mkAllConfigAttrs =
    let
      dirPath = ./.;
      contents = builtins.readDir dirPath;
      directories = builtins.filter (name: contents.${name} == "directory") (builtins.attrNames contents);
    in
      map (mkConfigAttrs) directories;
in
  builtins.listToAttrs mkAllConfigAttrs
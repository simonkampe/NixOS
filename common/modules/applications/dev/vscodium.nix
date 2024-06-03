{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    nil
    
    (vscode-with-extensions.override {
      vscode = vscodium;
      vscodeExtensions = with vscode-extensions; [
        jnoortheen.nix-ide
        ms-vscode.cmake-tools
        ms-vscode.cpptools
        ms-python.python
        ms-pyright.pyright
        editorconfig.editorconfig
      ];
    })
  ];
}

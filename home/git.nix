{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    aliases = {
      br = "branch -vv";
      c = "commit";
      co = "checkout";
      cp = "cherry-pick";
      d  = "diff";
      ds = "diff --staged";
      rb = "rebase";
      sh = "show";
      sm = "submodule";
      smu = "submodule update --recursive --init";
      st = "status";
      ll = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %Cgreen(%cr) %C(blue)[%an]%Creset' --branches --remotes --date=relative";
      lb = "log --graph --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %Cgreen(%cr) %C(blue)[%an]%Creset' --date=relative";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      ca = "submodule foreach git clean -ffdq";
      find = "log --all --pretty=format:'%C(yellow)%h%Creset -%C(red)%d%Creset %s %Cgreen(%cr) %C(blue)[%an]%Creset' --branches --name-status --grep";
      rah = "!git submodule foreach git clean -ffdq && git submodule foreach git reset --hard && git submodule update --recursive --init";
      amend = "commit --amend --date=now";
      list-untracked = "!git fetch --prune && git branch -vv | grep -v main | grep origin | grep gone";
      prune-untracked = "!git fetch --prune && git branch -vv | grep -v main | grep origin | grep gone | awk \"{print \$1}\" | xargs git branch -d";
    };

    # Include an identity file, for example:
    # [user]
    # name = Simon Kämpe
    # email = simon.kampe@gmail.com
    includes = [
      { path = "~/.config/git/gitidentity"; }
    ];

    ignores = [
      "*~"
      "*.swp"
      ".direnv"
      "devbox.json"
      "devbox.lock"
      ".devbox"
      ".envrc"
    ];

    extraConfig = {
      core = {
        fsync = "";
        editor = "hx";
        autocrlf = "input";
      };
      init = {
        defaultBranch = "main";
      };
      log = {
        follow = "true";
      };
      merge = {
        ff = "only";
      };
      pull = {
        ff = "only";
        rebase = "true";
      };
      push = {
        default = "current";
      };
      fetch = {
        prune = "true";
        pruneTags = "true";
      };
      rerere = {
        enabled = "true";
      };
    };
  };
}


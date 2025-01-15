{ config, pkgs, prepend_shell ? "", ... }:

{
  home.packages = with pkgs; [
    any-nix-shell
    xcp
  ];

  programs.nushell = {
    enable = true;
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${prepend_shell}

      set -gx EDITOR hx
      set -gx VISUAL hx
      set -gx NIX_SHELL_PRESERVE_PROMPT 1

      fish_add_path /home/simon/.cargo/bin
      fish_add_path /home/simon/.node_modules/bin

      set -gx ATUIN_NOBIND "true"
      atuin init fish | source

      # bind to ctrl-r in normal and insert mode, add any other bindings you want here too
      bind \cr _atuin_search
      bind -M insert \cr _atuin_search

      set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"

      any-nix-shell fish --info-right | source

      if type -q uwsm;
        if uwsm check may-start && uwsm select;
          exec systemd-cat -t uwsm_start uwsm start default;
        end
      end
    '';
    functions = {
      ducks = {
        body = ''
          sudo du -cks $argv | sort -rn | head
        '';
      };
      fish_greeting = {
        body = ''
          echo
          echo -e (uname -ro | awk '{print " \\\\e[1mOS: \\\\e[0;32m"$0"\\\\e[0m"}')
          echo -e (uptime | sed 's/^up //' | awk '{print " \\\\e[1mUptime: \\\\e[0;32m"$0"\\\\e[0m"}')
          echo -e (uname -n | awk '{print " \\\\e[1mHostname: \\\\e[0;32m"$0"\\\\e[0m"}')
          echo -e " \\e[1mDisk usage:\\e[0m"
          echo
          echo -ne (\
              df -l -h 2>/dev/null | grep -E 'dev/(nvme|xvda|sd|mapper)' | \
              awk '{printf "\\\\t%s\\\\t%4s / %4s  %s\\\\n\n", $6, $3, $2, $5}' | \
              sed -e 's/^\(.*\([8][5-9]\|[9][0-9]\)%.*\)$/\\\\e[0;31m\1\\\\e[0m/' -e 's/^\(.*\([7][5-9]\|[8][0-4]\)%.*\)$/\\\\e[0;33m\1\\\\e[0m/' | \
              paste -sd '''\
          )
          echo

          echo -e " \\e[1mNetwork:\\e[0m"
          echo
          # http://tdt.rocks/linux_network_interface_naming.html
          echo -ne (\
              ip addr show up scope global | \
                  grep -E ': <|inet' | \
                  sed \
                      -e 's/^[[:digit:]]\+: //' \
                      -e 's/: <.*//' \
                      -e 's/.*inet[[:digit:]]* //' \
                      -e 's/\/.*//'| \
                  awk 'BEGIN {i=""} /\.|:/ {print i" "$0"\\\n"; next} // {i = $0}' | \
                  sort | \
                  column -t -R1 | \
                  # public addresses are underlined for visibility \
                  sed 's/ \([^ ]\+\)$/ \\\e[4m\1/' | \
                  # private addresses are not \
                  sed 's/m\(\(10\.\|172\.\(1[6-9]\|2[0-9]\|3[01]\)\|192\.168\.\).*\)/m\\\e[24m\1/' | \
                  # unknown interfaces are cyan \
                  sed 's/^\( *[^ ]\+\)/\\\e[36m\1/' | \
                  # ethernet interfaces are normal \
                  sed 's/\(\(en\|em\|eth\)[^ ]* .*\)/\\\e[39m\1/' | \
                  # wireless interfaces are purple \
                  sed 's/\(wl[^ ]* .*\)/\\\e[35m\1/' | \
                  # wwan interfaces are yellow \
                  sed 's/\(ww[^ ]* .*\).*/\\\e[33m\1/' | \
                  sed 's/$/\\\e[0m/' | \
                  sed 's/^/\t/' \
              )
          echo

          set_color normal
        '';
      };
      wally = {
        body = ''
          set tmpfile (mktemp).bin
          wget https://oryx.zsa.io/$argv/latest/binary -O $tmpfile
          sudo wally-cli $tmpfile
        '';
      };
    };

    shellAbbrs = {
      clion = "clion . 1>/dev/null 2>&1 &";
      idea = "idea-ultimate . 1>/dev/null 2>&1 &";
      pycharm-ce = "pycharm-community . 1>/dev/null 2>&1 &";
      pycharm = "pycharm-professional . 1>/dev/null 2>&1 &";
      webstorm = "webstorm . 1>/dev/null 2>&1 &";
      rider = "rider . 1>/dev/null 2>&1 &";
      rust-rover = "rust-rover . 1>/dev/null 2>&1 &";
    };

    shellAliases = {
      flake = "nix flake";
      htop = "btop";
      top = "btop";
      cp = "xcp";
      cat = "bat";
      z = "zellij";
      za = "zellij attach";
      zs = "zellij --session";
    };
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = false; # This is added in fish config instead
  };

  programs.bat = {
    enable = true;
    config =  {
      theme = "Nord";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;

    settings = {
      command_timeout = 1000;
      os.disabled = false;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    extraOptions = [
      "--icons" "-F" "-H" "--group-directories-first" "--git" "-1"
    ];
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.zellij = {
    enable = true;
    #enableFishIntegration = true;
    settings = {
      theme = "nord";
      mouse_mode = false;
      pane_viewport_serialization = true;
      scrollback_lines_to_serialize = 1000;

      ui = {
        pane_frames = {
          rounded_corners = true;
        };
      };
    };
  };

  programs.btop = {
    enable = true;
  };
}

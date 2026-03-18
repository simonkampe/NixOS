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
      idea = "idea . 1>/dev/null 2>&1 &";
      pycharm = "pycharm . 1>/dev/null 2>&1 &";
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
      sshn = "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
      scpn = "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no";
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

      # optionally disable git modules when JJ is found.
      # note that you'll need to add ${custom.git_branch}, ${custom.git_commit} etc
      # into format: https://starship.rs/config/#default-prompt-format
      git_status.disabled = true;
      git_commit.disabled = true;
      git_state.disabled = true;
      git_metrics.disabled = true;
      git_branch.disabled = true;

      custom = {
        jj = {
          description = "The current jj status";
          when = "jj --ignore-working-copy root";
          symbol = "🥋 ";
          command = ''
          jj log --revisions @ --no-graph --ignore-working-copy --color always --limit 1 --template '
            separate(" ",
              change_id.shortest(4),
              bookmarks,
              "|",
              concat(
                if(conflict, "💥"),
                if(divergent, "🚧"),
                if(hidden, "👻"),
                if(immutable, "🔒"),
              ),
              raw_escape_sequence("\x1b[1;32m") ++ if(empty, "(empty)"),
              raw_escape_sequence("\x1b[1;32m") ++ coalesce(
                truncate_end(29, description.first_line(), "…"),
                "(no description set)",
              ) ++ raw_escape_sequence("\x1b[0m"),
            )
          '
          '';
        };

        git_status = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_status";
          style = ""; # This disables the default "(bold green)" style
          description = "Only show git_status if we're not in a jj repo";
        };

        git_commit = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_commit";
          style = "";
          description = "Only show git_commit if we're not in a jj repo";
        };

        git_state = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_state";
          style = "";
          description = "Only show git_state if we're not in a jj repo";
        };

        git_metrics = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_metrics";
          style = "";
          description = "Only show git_metrics if we're not in a jj repo";
        };

        git_branch = {
          when = "! jj --ignore-working-copy root";
          command = "starship module git_branch";
          style = "";
          description = "Only show git_branch if we're not in a jj repo";
        };
      };

      format = pkgs.lib.strings.stringAsChars (x: if x == " " || x == "\n" then "" else x) "
      $username
      $hostname
      $localip
      $shlvl
      $singularity
      $kubernetes
      $directory
      $vcsh
      $fossil_branch
      $fossil_metrics
      $\{custom.jj\}
      $\{custom.git_branch\}
      $\{custom.git_commit\}
      $\{custom.git_state\}
      $\{custom.git_metrics\}
      $\{custom.git_status\}
      $hg_branch
      $hg_state
      $pijul_channel
      $docker_context
      $package
      $c
      $cmake
      $cobol
      $daml
      $dart
      $deno
      $dotnet
      $elixir
      $elm
      $erlang
      $fennel
      $fortran
      $gleam
      $golang
      $guix_shell
      $haskell
      $haxe
      $helm
      $java
      $julia
      $kotlin
      $gradle
      $lua
      $nim
      $nodejs
      $ocaml
      $opa
      $perl
      $php
      $pulumi
      $purescript
      $python
      $quarto
      $raku
      $rlang
      $red
      $ruby
      $rust
      $scala
      $solidity
      $swift
      $terraform
      $typst
      $vlang
      $vagrant
      $zig
      $buf
      $nix_shell
      $conda
      $meson
      $spack
      $memory_usage
      $aws
      $gcloud
      $openstack
      $azure
      $nats
      $direnv
      $env_var
      $mise
      $crystal
      $custom
      $sudo
      $cmd_duration
      $line_break
      $jobs
      $battery
      $time
      $status
      $os
      $container
      $netns
      $shell
      $character
      ";
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
    enableFishIntegration = false;
    settings = {
      theme = "nord";
      mouse_mode = false;
      pane_viewport_serialization = true;
      scrollback_lines_to_serialize = 1000;
      pane_frames = false;

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

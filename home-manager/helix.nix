{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "nord";

      editor = {
        scrolloff = 5;
        mouse = true;
        middle-click-paste = true;
        scroll-lines = 3;
        shell = [ "sh" "-c" ];
        line-number = "relative";
        cursorline = true;
        cursorcolumn = false;
        gutters = ["diagnostics" "spacer" "line-numbers" "spacer" "diff"];
        auto-completion = true;
        auto-format = true;
        auto-save = false;
        idle-timeout = 400;
        completion-trigger-len = 2;
        completion-replace = true;
        auto-info = true;
        true-color = false;
        undercurl = false;
        rulers = [ 80 ];
        bufferline = "multiple";
        color-modes = true;
        text-width = 80;
        workspace-lsp-roots = [];

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        file-picker = {
          hidden = false;
          follow-symlinks = true;
          deduplicate-links = true;
          parents = true;
          ignore = true;
          git-ignore = true;
          git-global = false;
          git-exclude = false;
          #max-depth = None;
        };

        lsp = {
          enable = true;
          display-messages = true;
          auto-signature-help = true;
          display-inlay-hints = true;
          display-signature-help-docs = true;
          snippets = true;
          #goto-references-include-declaration = true;
        };

        search = {
          smart-case = true;
          wrap-around = true;
        };

        whitespace = {
          render = {
            tab = "all";
            space = "none";
            nbsp = "none";
            newline = "none";
            tabpad = "all";
          };
          characters = {
            space = " ";
            nbsp = "⍽";
            tab = "→";
            newline = "⏎";
            tabpad = " "; # Tabs will look like "→···" (depending on tab width)
          };
        };

        indent-guides = {
          render = true;
          character = "▏"; # Some characters that work well: "▏", "┆", "┊", "⸽"
          skip-levels = 1;
        };

      };
    };
  };
}


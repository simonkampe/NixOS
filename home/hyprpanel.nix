{ inputs, pkgs, ... }:

{
  imports = [
    inputs.hyprpanel.homeManagerModules.hyprpanel
  ];

  home.packages = with pkgs; [
    python3Full
    gpustat
    brightnessctl
    grimblast
    gpu-screen-recorder
    hyprpicker
    hyprsunset
    hypridle
    hyprlock
    btop
  ];

  programs.hyprpanel = {
    # Enable the module.
    # Default: false
    enable = true;

    # Automatically restart HyprPanel with systemd.
    # Useful when updating your config so that you
    # don't need to manually restart it.
    # Default: false
    systemd.enable = true;

    # Add '/nix/store/.../hyprpanel' to the
    # 'exec-once' in your Hyprland config.
    # Default: false
    hyprland.enable = false;

    # Fix the overwrite issue with HyprPanel.
    # See below for more information.
    # Default: false
    overwrite.enable = true;

    # Import a specific theme from './themes/*.json'.
    # Default: ""
    theme = "one_dark_split";

    # Configure bar layouts for monitors.
    # See 'https://hyprpanel.com/configuration/panel.html'.
    # Default: null
    layout = {
      "bar.layouts" = {
        "*" = {
          left = [ "power" "hypridle" "hyprsunset" "workspaces" ];
          middle = [ "media" "clock" "notifications" ];
          right = [ "volume" "network" "bluetooth" "battery" "systray" ];
        };
      };
    };

    # Configure and theme *most* of the options from the GUI.
    # See './nix/module.nix:103'.
    # Default: <same as gui>
    settings = {
      bar = {
        launcher.autoDetectIcon = true;

        workspaces = {
          showApplicationIcons = false;
          showWsIcons = true;
          applicationIconOncePerWorkspace = false;
          workspaces = 1;
          monitorSpecific = false;
          spacing = 1;
          ignored = "-98";
        };
        
        clock = {
          format = "%Y-%m-%d | %H:%M";
        };

        customModules.power = {
          showLabel = false;
        };
      };

      menus = {
        clock = {
          time = {
            military = true;
            hideSeconds = true;
          };

          weather = {
            enabled = false;
            location = "Orebro";
            unit = "metric";
          };
        };

        dashboard = {
          directories.enabled = false;
          shortcuts.enabled = false;
          stats.enable_gpu = true;
        };

        power = {
          confirmation = false;
          lowBatteryNotification = true;
        };
      };

      notifications = {
        position = "top center";
      };

      theme = {
        bar.transparent = true;

        font = {
          name = "Noto Sans";
          size = "13px";
        };
      };
    };

    override = {
      theme.bar.buttons.workspaces.active = "#61AFEF";
      theme.bar.buttons.workspaces.hover = "#61AFEF";
      theme.bar.buttons.workspaces.numbered_active_underline_color = "#61AFEF";
      theme.bar.buttons.workspaces.numbered_active_highlighted_text_color = "#61AFEF";

      app.icon.mappings = {
        "[dD]iscord" = "󰙯";
        "title:YouTube" = "";
        "ghostty" = "";
      };
    };
  };
}

{ self, pkgs, lib, ...}:

{
  programs.hyprpanel = {
    enable = true;
    settings = {
      bar = {
        layouts = {
          "*" = {
            left = [ "dashboard" "workspaces" ];
            middle = [ ];
            right = [ "volume" "network" "bluetooth" "systray" "battery" "notifications" "clock" ];
          };
        };
        dashboards= {
          directories = {
            enabled = false;
          };
          resourceUsage = {
            enabled = false;
          };
        };
        workspaces = {
          show_numbers = false;
          show_icons = true;
        };
        volume = {
          label = false;
        };
        network = {
          label = false;
        };
        bluetooth = {
          label = false;
        };
        battery = {
          label = false;
        };
        clock = {
          format = "%H:%M";
        };
        launcher = {
          autoDetectIcon = true;
        };
      };

      menus = {
        dashboard = {
          directories.enabled = false;
          stats.enable_gpu = true;
        };

        clock = {
          time = {
            enabled = true;
            military = true;
            hideSeconds = false;
          };
          weather = {
            enabled = false;
          };
        };
      };

      theme = {
        bar.transparent = true;
        font = {
          name = "CaskaydiaCove NF";
          size = "14px";
        };
      };

    };
  };
}

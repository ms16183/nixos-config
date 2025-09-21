{ self, pkgs, lib, ...}:

{
  wayland.windowManager.hyprland = {
    
    enable = true;

    settings = {

      "$terminal" = "alacritty";
      "$filer" = "ranger";
      "$mainMod" = "SUPER";
      "$editor" = "vim";
      "$launcher" = "rofi";

      exec = [
        "fcitx5"
        "killall -q hyprpanel ; sleep .5 ; hyprpanel"
      ];

      general = {
        gaps_in = 3;
        gaps_out = 5;
        border_size = 3;

        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 0.95;
        inactive_opacity = 0.90;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
        shadow = {
          enabled = false;
        };
      };

      input = {
        kb_layout = "us";

        follow_mouse = 1;
        sensitivity = 0;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 2;
        disable_hyprland_logo = false;

        animate_manual_resizes = true;
      };

      bindl = [
        ",switch:off:Lid Switch, exec, hyprlock --immediate-render"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      bind = [
        "$mainMod, RETURN, exec, $terminal"
        "$mainMod, E, exec, $filer"
        "$mainMod, R, exec, $launcher -show drun"
        "$mainMod, P, exec, hyprctl reload"
        "$mainMod, Q, killactive"
        "$mainMod, M, Exit"
        "$mainMod, D, exec, brave"

        "$mainMod, V, togglefloating"

        "$mainMod, F, fullscreen, 0"

        "$mainMod,  left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod,    up, movefocus, u"
        "$mainMod,  down, movefocus, d"

        "$mainMod ALT,  left, swapwindow, l"
        "$mainMod ALT, right, swapwindow, r"
        "$mainMod ALT,    up, swapwindow, u"
        "$mainMod ALT,  down, swapwindow, d"

        "$mainMod SHIFT,  LEFT, resizeactive, -100, 0"
        "$mainMod SHIFT, right, resizeactive,  100, 0"
        "$mainMod SHIFT,    up, resizeactive, 0, -100"
        "$mainMod SHIFT,  down, resizeactive, 0,  100"

      ]
      ++ (
        builtins.concatLists (
          builtins.genList (i:
            let
              ws = i + 1;
            in [
              "$mainMod      , code:1${toString i}, workspace, ${toString ws}"
              "$mainMod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          )
        9)
      );

    };
  };

  #home.pointerCursor.hyprcursor = {
  #  enable = true;
  #  size = 24;
  #};

  programs.hyprlock = {
    enable = true;
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = true;
      splash_offset = 2.0;

      #preload = [ " " ];

      #wallpaper = [
      #  "DP-1,"
      #  "DP-2,"
      #];
    };
  };

  services.hypridle = {
    enable = true;
  };

  services.hyprsunset = {
    enable = true;
  };

  services.hyprpolkitagent = {
    enable = true;
  };

}


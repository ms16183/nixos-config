{ self, pkgs, lib, ...}:

{

  wayland.windowManager.hyprland = {
    
    enable = true;

    settings = {

      "$terminal" = "alacritty";
      "$mainMod" = "SUPER";
      "$editor" = "vim";

      exec = [
        "fcitx5"
        "killall -q hyprpanel ; sleep .5 ; hyprpanel"
      ];

      input = {
        kb_layout = "us";
        #kb_variant ="alt-intl";

        follow_mouse = 1;
        sensitivity = 0;
      };

      bind = [
        "$mainMod, RETURN, exec, alacritty"
        "$mainMod, Q, killactive"
        "$mainMod, M, Exit"
        "$mainMod, D, exec, brave"
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


{ self, pkgs, lib, ...}:

{
  home.packages = with pkgs; [
    xborders
  ];
  home.file.".config/xborder/config.json".source = ./xborder.json;

  xsession.windowManager.i3 = {

    enable = true;
    config = let
      mod = "Mod4"; # win
    in {
      # mod key
      modifier = "${mod}";

      # keybinding
      keybindings = lib.mkOptionDefault {
        "${mod}+Return" = "exec alacritty";
        "${mod}+d" = "exec rofi -show drun";
      };

      # workspaces
      defaultWorkspace = "workspace number 1";

      # startup with polybar
      startup = [
        {
          command = "systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        {
          command = "feh --bg-fill $HOME/.config/wallpaper/nix-black-4k.png";
          always = true;
          notification = false;
        }
        {
          command = "picom --config $HOME/.config/picom/picom.conf";
          always =  true;
          notification = false;
        }
        {
          command = "xborders -c $HOME/.config/xborder/config.json";
          always =  true;
          notification = false;
        }
        {
          command = "fcitx5";
        }
        {
          command = "alacritty";
        }
      ];

      # use polybar instead.
      bars = [];

      # window gaps
      gaps = {
        #smartGaps = true;
        inner = 10;
        outer = 5;
      };

      # window design
      window = {
        titlebar = false;
        border = 0;
      };
    };
  };
}

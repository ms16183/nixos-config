{ self, pkgs, lib, ...}:

{
  wayland.windowManager.hyprland = {

    enable = true;
    # hyprlang was deprecated in Hyprland 0.55 in favor of this lua config
    # (home.stateVersion is 25.05, so the module's own default would still
    # pick "hyprlang" here without this override).
    configType = "lua";

    # Kept in a plain .lua file (hyprland.lua) rather than inlined here,
    # since binds need `hl.dsp.*` dispatcher calls as arguments and writing
    # that through `settings` would mean wrapping every one of them in
    # `lib.generators.mkLuaInline` from the Nix side for little benefit.
    extraConfig = builtins.readFile ./hyprland.lua;
  };

  # screenshot: win+shift+s copies a region selection to the clipboard
  home.packages = [ pkgs.grimblast ];

  #home.pointerCursor.hyprcursor = {
  #  enable = true;
  #  size = 24;
  #};

  programs.hyprlock = {
    enable = true;

    # centered clock over the live desktop (a screenshot taken at lock time,
    # blurred to match the bar), matched to vast-shell's Lock-Screen. colors
    # are Catppuccin Frappe to match the bar (home/miu/wayland/quickshell).
    settings = {
      general = {
        hide_cursor = false;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_size = 3;
          blur_passes = 2;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 90;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(198, 208, 245)"; # frappe text
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:60000] date +"%A, %B %d"'';
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          color = "rgb(198, 208, 245)"; # frappe text
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [
        {
          size = "20%, 5%";
          outline_thickness = 3;
          inner_color = "rgba(48, 52, 70, 0.4)"; # frappe base
          outer_color = "rgba(140, 170, 238, 0.8)"; # frappe blue
          check_color = "rgba(166, 209, 137, 0.9)"; # frappe green
          fail_color = "rgba(231, 130, 132, 0.9)"; # frappe red
          font_color = "rgb(198, 208, 245)"; # frappe text
          fade_on_empty = false;
          rounding = 20;
          font_family = "JetBrainsMono Nerd Font";
          placeholder_text = "Password...";
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = true;
      splash = true;
      splash_offset = 2;

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


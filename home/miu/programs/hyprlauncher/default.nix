{ ... }:

{
  services.hyprlauncher = {
    enable = true;
    settings = {
      general = {
        grab_focus = true;
      };
      cache = {
        enabled = true;
      };
      finders = {
        default_finder = "desktop";
        desktop_icons = true;
      };
      ui = {
        window_size = "480 320";
      };
    };
  };

  xdg.configFile."hypr/hyprtoolkit.conf".text = ''
    font_family = JetBrainsMono Nerd Font
    font_family_monospace = JetBrainsMono Nerd Font
    rounding_large = 20
    rounding_small = 10
  '';
}

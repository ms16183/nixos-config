{ lib, pkgs, ...}:

{
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      local config = {}
      config.enable_tab_bar = false

      return config
    '';
  };
}

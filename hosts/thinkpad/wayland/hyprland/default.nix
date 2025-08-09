{config, lib, pkgs, ...}:

{
  services.xserver = {
    enable = false;
  };

  programs.hyprland = {
    enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
    ];
  };

  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };

  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        editor = "vim";
        #animation = "matrix";
        save = true;
      };
    };
    defaultSession = "Hyprland";
  };
}


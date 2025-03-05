{config, lib, pkgs, ...}:

{
  environment.pathsToLink = [ "/libexec" ];

  # i3+lightdm
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      #runXdgAutostartIfNone = true;
    };
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        i3lock
      ];
    };
    displayManager.lightdm = {
      enable = true;
      background = ./nix-black-4k.png;
      greeters.gtk = {
        indicators = [
          "~spacer"
          "~clock"
          "~session"
          "~language"
          "~a11y"
          "~power"
        ];
        theme.package = pkgs.arc-icon-theme;
        theme.name = "Arc-Dark";

        cursorTheme.package = pkgs.arc-icon-theme;
        cursorTheme.name = "Arc-Dark";

        iconTheme.package = pkgs.arc-theme;
        iconTheme.name = "Arc-Dark";
      };
    };
  };
  # screen lock
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.i3lock}/bin/i3lock";
  };

  # default session
  services.displayManager = {
    defaultSession = "none+i3";
  };
}

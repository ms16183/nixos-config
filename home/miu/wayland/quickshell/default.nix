{ pkgs, ... }:

{
  home.packages = [
    # icon theme for the bar's IconImage lookups (Quickshell.iconPath),
    # since hyprpanel's gtk.iconTheme is no longer active while it's unimported
    pkgs.adwaita-icon-theme
    # nm-connection-editor, opened by NetworkStatus.qml's click handler
    pkgs.networkmanagerapplet
  ];

  programs.quickshell = {
    enable = true;
    activeConfig = "default";
    configs.default = ./config;

    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
  };
}

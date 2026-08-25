{ lib, pkgs, username, catppuccin, stylix, ...}:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  imports = [
    #./programs/alacritty
    ./programs/wezterm
    ./programs/git
    ./programs/mpd
    ./programs/vim
    ./programs/zsh
    #./programs/rofi
    ./programs/hyprlauncher
    ./programs/fastfetch

    ./wayland/hyprland
    #./wayland/hyprpanel
    ./wayland/quickshell

    #./xorg/dunst
    #./xorg/i3wm
    #./xorg/picom
    #./xorg/polybar
  ];

  stylix = {
    enable = true;

    # matches the Catppuccin Frappe used by the QuickShell bar/hyprlock
    # (which stylix doesn't theme itself — no quickshell target exists),
    # so autoEnable'd apps (terminal, GTK, rofi, qt, ...) match too.
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";
    polarity = "dark";

    autoEnable = true;

    # the NixOS-level stylix module (hosts/thinkpad/default.nix's stylix
    # import) already applies stylix's package overlay to the shared pkgs;
    # with home-manager.useGlobalPkgs, this home-manager-level copy of the
    # same overlay is discarded anyway, just with a deprecation warning.
    overlays.enable = false;

    targets = {
      # hyprlock is hand-themed with Catppuccin Frappe in
      # wayland/hyprland/default.nix (matching the quickshell bar); stylix's
      # own hyprlock target sets `settings.background` as an attrset while
      # ours is a list, which conflicts ("defined multiple times").
      hyprlock.enable = false;
      /*
      alacritty.enable = false;
      */
    };

    opacity = {
      applications = 1.00;
      terminal = 0.95;
      popups = 0.90;
    };
  };

  home.packages = with pkgs; [
    # browser
    brave
    # music player
    moc
    mpd
    ncmpcpp
    spotify-player
    # image viewer
    feh
    vlc
    mcomix
    # filer
    ranger
    # python
    python314
    # C/C++
    libgcc
    # AI coding
    claude-code
    # analyze
    gdb
    radare2
    # learning
    obsidian
    # crypt
    veracrypt
    # social
    discord
    # util
    eza
    bat
    gotop
    cava
    figlet
    cowsay
    tty-clock
    pfetch
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      # pin the pre-26.05 default (XDG_*_DIR session vars exported) rather
      # than silently dropping them.
      setSessionVariables = true;
    };
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}

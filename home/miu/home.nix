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
    ./programs/rofi
    ./programs/fastfetch

    ./wayland/hyprland
    ./wayland/hyprpanel

    #./xorg/dunst
    #./xorg/i3wm
    #./xorg/picom
    #./xorg/polybar
  ];

  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/tokyo-night-dark.yaml";
    polarity = "dark";

    autoEnable = true;
    /*
    targets = {
      alacritty.enable = false;
    };
    */

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
    # analyze
    gdb
    radare2
    # learning
    obsidian
    # crypt
    veracrypt
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
    };
  };

  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}

{ lib, pkgs, username, catppuccin, ...}:

{
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  imports = [
    ./programs/alacritty
    ./programs/git
    ./programs/mpd
    ./programs/vim
    ./programs/zsh

    ./xorg/dunst
    ./xorg/i3wm
    ./xorg/picom
    ./xorg/polybar
    ./xorg/rofi
  ];

  catppuccin = {
    flavor = "frappe";

    alacritty.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;

    dunst.enable = true;
    polybar.enable = true;
    rofi.enable = true;

    fcitx5.enable = true;
    cava.enable = true;
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
    ida-free
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

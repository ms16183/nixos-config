{ lib, pkgs, ...}:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.95;
      window.padding.x = 5;
      window.padding.y = 5;
    };
  };
}

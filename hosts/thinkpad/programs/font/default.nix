{ config, lib, pkgs, ...}:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      #nerdfonts
      nerd-fonts.noto           # for polybar settings
      nerd-fonts.jetbrains-mono
      siji
      symbola
      font-awesome
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji"];
        sansSerif = ["Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji" "NerdFont"]; 
      };
    };
  };
}

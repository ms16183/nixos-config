{ config, lib, pkgs, ...}:

{
  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-serif
      noto-fonts-cjk-sans
      noto-fonts-emoji
      #nerdfonts
      nerd-fonts.noto           # for polybar settings
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      twemoji-color-font
      rictydiminished-with-firacode
      siji
      #symbola                  # this font cannot install because source(archive.org) dropped it.
      font-awesome
      hicolor-icon-theme
      adwaita-icon-theme
    ];
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif CJK JP" "Noto Color Emoji" "Twemoji"];
        sansSerif = ["JetBrainsMono Nerd Font" "Symbols Nerd Font" "Twemoji" "Noto Sans CJK JP" "Noto Color Emoji"];
        monospace = ["JetBrainsMono Nerd Font" "Symbols Nerd Font" "Twemoji" "Noto Color Emoji"];
        emoji = ["Noto Color Emoji" "JetBrainsMono NerdFont" "Symbols Nerd Font" "Twemoji" ]; 
      };
    };
  };
}

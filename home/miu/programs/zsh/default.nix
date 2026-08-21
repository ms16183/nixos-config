{ lib, pkgs, config, ...}:

{
  programs.zsh = {
    enable = true;
    # opt into the post-26.05 default: keep zsh dotfiles under
    # $XDG_CONFIG_HOME instead of loose in $HOME.
    dotDir = "${config.xdg.configHome}/zsh";
    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {

      ll = "ls -l";
      la = "ls -a";
      rm = "rm -i";
      cp = "cp -i";
      mv = "mv -i";

      ".." = "cd ..";
      "...." = "cd ../..";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ./starship.toml) ;
  };
}

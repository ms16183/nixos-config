{ lib, pkgs, ...}:

{
  programs.zsh = {
    enable = true;
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

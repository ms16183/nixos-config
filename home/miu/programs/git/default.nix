{ lib, pkgs, ...}:

{
  programs.git = {
    enable = true;
    userEmail = "ms21826@outlook.com";
    userName = "ms16183";
    aliases = {
      d = "diff";
      s = "status";
      l = "log --graph --oneline";
      g = "log --graph";
      co = "checkout";
    };
    extraConfig = {
      core = {
        editor = "vim";
      };
    };
  };

  programs.lazygit = {
    enable = true;
  };
}

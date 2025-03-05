{ lib, pkgs, ...}:

{
  programs.git = {
    enable = true;
    userEmail = "ms21826@outlook.com";
    userName = "ms16183";
    aliases = {
      s = "status";
      l = "log --graph --oneline";
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

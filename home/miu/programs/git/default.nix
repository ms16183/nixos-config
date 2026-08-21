{ lib, pkgs, ...}:

{
  programs.git = {

    enable = true;

    settings = {

      user = {
        email = "ms21826@outlook.com";
        name = "ms16183";
      };

      alias = {
        d = "diff";
        s = "status";
        l = "log --graph --oneline";
        g = "log --graph";
        co = "checkout";
        sw = "switch";
      };

      core = {
        editor = "vim";
      };
      
    };
  };

  programs.lazygit = {
    enable = true;
  };
}

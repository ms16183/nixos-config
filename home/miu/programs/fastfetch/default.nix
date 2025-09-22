{lib, ...}:

{
  programs.fastfetch = {
    enable = true;

    settings = {

      logo = {
        source = ./logo/lain.png;
        type = "kitty";
        #width = 28;
        #height = 28;
        position = "left";
        padding = {
          right = 1;
        };
      };

      display = {
        separator = "";
      };

      modules = [
        {
          type = "custom";
          format = "";
        }
        {
          type = "host";
          key = "HOST ";
          keyColor = "yellow";
        }
        {
          type = "custom";
          format = "";
        }
        {
          type = "os";
          key = "  ";
        }
        {
          type = "kernel";
          key = "  ";
        }
        {
          type = "cpu";
          key = "  ";
        }
        {
          type = "memory";
          key = "  ";
        }
        {
          type = "shell";
          key = "  ";
        }
        {
          type = "terminal";
          key = "  ";
        }
        {
          type = "wm";
          key = " 󰕮 ";
        }
        {
          type = "uptime";
          key = "  ";
        }
        "break"
        #"colors"
        {
          type = "custom";
          format = "";
        }
      ];

    };

  };
}

{pkgs, ...}:

{
  services.picom = {
    enable = true;
    settings = {

      shadow = false;

      corner-radius = 8;
      rounded-corners-exclude = [
        "class_g = 'Fcitx5 Input Window'"
        "class_g = 'Polybar'"
      ];

      #backend = "glx";
      #blur-method = "dual_kawase";
      #blur-strength = 3;
      #blur-background = true;
      #blur-background-fixed = false;
      #blur-background-frame = false;
      #blur-background-exclude = [
      #  "role = 'xborder'"
      #];

      fading = true;
      fade-in-step = 0.0066;
      fade-out-step = 0.01;
      fade-delta = 1;
      
      menu-opacity = 0.9;
      frame-opacity = 0.9;
      active-opacity = 0.9;
      inactive-opacity = 0.8;
      opacity = 0.9;
      opacity-rule = [
        "80:class_g = 'Polybar'"
      ];
    };
  };
}

{pkgs, lib, ...}:

{
  services.polybar = {
    enable = true;
    script = "polybar top &";
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
      mpdSupport = true;
    };
    extraConfig = builtins.readFile ./config.ini;
  };
}

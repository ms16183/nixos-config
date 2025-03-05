{pkgs, ...}:

{
  services.mpd = {
    enable = true;
    dbFile = "$HOME/.config/mpd/database";
    #logFile = "$HOME/.config/mpd/log";
    musicDirectory = "$HOME/Music";
  };
}

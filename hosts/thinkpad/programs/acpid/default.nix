{ config, lib, pkgs, ... }:

{
  services.acpid = {
    enable = true;
    lidEventCommands = "i3lock";
  };
}

# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, nixos-hardware, username, host, catppuccin, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./programs/i18n
    ./programs/font

    ./xorg/i3wm

    nixos-hardware.nixosModules.lenovo-thinkpad-l480
  ];

  catppuccin = {
    flavor = "frappe";
    fcitx5.enable = true;
  };

  # os user
  users.users = {
    ${username} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };

  # bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  
  # network
  networking = {
    hostName = "nix";
    networkmanager.enable = true;
    #wireless.enable = true;
    #proxy.default = "http://user:password@proxy:port/";
    #proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # access
  security = {
     rtkit.enable = true;
    polkit.enable = true;
  };

  # time zone
  time.timeZone = "Asia/Tokyo";

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      #trusted-users = [ "${username}" ];
      #substituters = [
      #  "https://nix-community.cachix.org"
      #];
      #trusted-publick-keys = [
      #  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      #];
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
  };

  # sound
  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };
  services.power-profiles-daemon = {
    enable = true;
  };

  # S.M.A.R.T.
  services.smartd = {
    enable = false;
    autodetect = true;
  };

  # commands
  environment.systemPackages = with pkgs; [
    # compression
    xz
    zip
    unzip
    # editor
    vim
    # util
    jq
    git
    file
    curl
    wget
    lsof
    killall
    # system call
    ltrace
    strace
    # hardware
    lshw
    sysstat
    pciutils
    usbutils
    # network
    dnsutils
    nmap
    # visualization
    tree
    # audio
    pulseaudio
    pavucontrol
    pamixer
    # wireless
    wirelesstools
  ];

  system.stateVersion = "24.11";
}


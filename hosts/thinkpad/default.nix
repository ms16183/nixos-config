# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, nixos-hardware, xremap, username, host, catppuccin, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./programs/i18n
    ./programs/font
    ./programs/tlp

    #./xorg/i3wm
    ./wayland/hyprland

    nixos-hardware.nixosModules.lenovo-thinkpad-x280
    xremap.nixosModules.default
  ];

  services.xremap = {
    userName = "${username}";
    serviceMode = "system";
    config = {
      modmap = [
        {
          name = "CapsLock -> Ctrl";
          remap = { CapsLock = "Ctrl_L"; };
        }
        {
          name = "Ctrl -> CapsLock";
          remap = { Ctrl_L = "CapsLock"; };
        }
      ];
    };
  };

  services.udev = {
    enable = true;
    extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chmod o+w /sys/class/backlight/intel_backlight/brightness"
    '';
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
      trusted-users = [ "${username}" ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
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
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    jack.enable = true;
    pulse.enable = true;
  };

  #services.power-profiles-daemon = {
  #  enable = true;
  #};

  # S.M.A.R.T.
  services.smartd = {
    enable = false;
    autodetect = true;
  };

  # battery
  services.upower = {
    enable = true;
  };

  # bluetooth
  services.blueman = {
    enable = true;
  };
  hardware.bluetooth = {
    enable = true;
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
    bluez
    bluez-tools
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
    # backlight
    brightnessctl
  ];

  system.stateVersion = "25.05";
}


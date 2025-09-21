## My NixOS

### how to use
You define your name and your host.

```bash
$ vim flake.nix
  ...
  } @ inputs :
  let
    username = "your name";
    host = "your host";
  in {
    nixosConfigurations = {
  ...

```
Build it.
```bash
$ sudo nixos-generate-config --show-hardware-config > hosts/"your host"/hardware-configuration.nix
$ sudo nixos-rebuild switch --flake .#"your host"
$ shutdown -r now
```

### structure
```
.
├── flake.lock
├── flake.nix
├── home
│   └── "your name"
│       ├── home.nix
│       ├── programs
│       │   ├── alacritty
│       │   │   └── default.nix
│       │   └── "tool name"
│       │       └── default.nix
│       ├── wayland
│       │   ├── hyprland
│       │   │   └── default.nix
│       │   └── hyprpanel
│       │       └── default.nix
│       └── xorg
│           ├── dunst
│           │   └── default.nix
│           ├── i3wm
│           │   ├── default.nix
│           │   └── xborder.json
│          ...
├── hosts
│   └── "your host"
│       ├── default.nix
│       ├── hardware-configuration.nix
│       ├── programs
│       │   ├── font
│       │   │   └── default.nix
│       │   └── "tools"
│       │       └── default.nix
│       ├── wayland
│       │   └── hyprland
│       │       └── default.nix
│       └── xorg
│           └── i3wm
│               ├── default.nix
│               └── nix-black-4k.png
└── README.md
```

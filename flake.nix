{
  description = "miu's os";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-24.11";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap = {
      url = "github:xremap/nix-flake";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };
  };

  outputs = { 
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    xremap,
    catppuccin,
    ... 
  } @ inputs:
  let
    username = "miu"; 
    host = "thinkpad"; 
  in {
    nixosConfigurations = {

      ${host} = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs nixos-hardware xremap username host catppuccin; };

        modules = [
          ./hosts/${host}
          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true; 
            home-manager.useUserPackages = true; 
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username host catppuccin; };
            home-manager.users.${username} = {
              imports = [
                ./home/${username}/home.nix
                catppuccin.homeManagerModules.catppuccin
              ];
            };
          }
        ];
      };

    };
  };
}

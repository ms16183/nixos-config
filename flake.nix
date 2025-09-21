{
  description = "miu's os";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap = {
      url = "github:xremap/nix-flake";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.05";
    };
  };

  outputs = { 
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    xremap,
    catppuccin,
    stylix,
    ... 
  } @ inputs:
  let
    username = "miu"; 
    host = "thinkpad"; 
  in {
    nixosConfigurations = {

      ${host} = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        specialArgs = { inherit inputs nixos-hardware xremap username host catppuccin stylix; };

        modules = [
          ./hosts/${host}
          #catppuccin.nixosModules.catppuccin
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager {
            home-manager.useGlobalPkgs = true; 
            home-manager.useUserPackages = true; 
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit inputs username host catppuccin; };
            home-manager.users.${username} = {
              imports = [
                ./home/${username}/home.nix
                #catppuccin.homeModules.catppuccin
                stylix.homeModules.stylix
              ];
            };
          }
        ];
      };

    };
  };
}

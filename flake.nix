{
  description = "The flake configuration of my NixOS machine";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur.url = "github:nix-community/NUR";
    nixvim.url = "github:mikaelfangel/nixvim-config";
  };

  outputs = inputs@{self, nixpkgs, home-manager, nur, ...}:
  {
    nixosConfigurations = {

      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
	  nur.nixosModules.nur
        ];
        specialArgs = { inherit inputs; };
      };
    };
  };
}

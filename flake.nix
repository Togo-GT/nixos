{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }@inputs: {
    nixosConfigurations = {
      # Your NixOS host configuration (if any)
    };

    homeConfigurations = {
      # Replace "gt" with your username
      "gt" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux; # Adjust system if needed
        modules = [
          ./home.nix  # Your Home Manager configuration
          # Add other modules if needed
        ];
        extraSpecialArgs = { inherit inputs; }; # If you need to pass inputs to home.nix
      };
    };
  };
}

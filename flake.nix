{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      "nixos-btw" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix  # eller din konfigurationsfil
          home-manager.nixosModules.home-manager
          {
            home-manager.users.gt = import ./home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      "Togo-GT" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
  };
}

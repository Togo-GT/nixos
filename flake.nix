{
  description = "NixOS config for nixos-btw with Home Manager ✨";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    # ---- NixOS system configuration ----
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.Togo-GT = import ./home.nix;
        }
      ];
    };

    # ---- Home Manager standalone configuration ----
    homeConfigurations.Togo-GT = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  };
}

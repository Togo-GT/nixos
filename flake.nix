{
  description = "NixOS config for nixos-btw with Home Manager ✨";

  inputs = {
    # 📦 NixOS officielle kanaler
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 🏠 Home Manager integration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux"; # 🖥 Din maskine
    in {
      nixosConfigurations = {
        nixos-btw = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./configuration.nix     # 💻 System-konfiguration
            home-manager.nixosModules.home-manager

            {
              # 🏠 Home Manager settings
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;

              home-manager.users.gt = import ./home.nix;
            }
          ];
        };
      };
    };
}

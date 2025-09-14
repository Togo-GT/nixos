{
  description = "NixOS 25.05 config for nixos-btw with Home Manager ✨";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [

        # ----------------------------
        # Hardware config
        # ----------------------------
        ({ lib, config, ... }: {
          boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
          boot.initrd.kernelModules = [ ];
          boot.kernelModules = [ "kvm-intel" ];
          boot.extraModulePackages = [ ];

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/8f424373-0299-411b-82ba-475f6289a59d";
            fsType = "ext4";
          };

          swapDevices = [ ];
          networking.useDHCP = lib.mkDefault true;

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        })

        # ----------------------------
        # System basics
        # ----------------------------
        {
          boot.loader.grub.enable = true;
          boot.loader.grub.device = "/dev/sda";
          boot.loader.grub.useOSProber = true;

          networking.hostName = "nixos-btw";
          networking.networkmanager.enable = true;

          time.timeZone = "Europe/Copenhagen";

          i18n.defaultLocale = "en_DK.UTF-8";
          i18n.extraLocaleSettings = {
            LC_ADDRESS = "da_DK.UTF-8";
            LC_IDENTIFICATION = "da_DK.UTF-8";
            LC_MEASUREMENT = "da_DK.UTF-8";
            LC_MONETARY = "da_DK.UTF-8";
            LC_NAME = "da_DK.UTF-8";
            LC_NUMERIC = "da_DK.UTF-8";
            LC_PAPER = "da_DK.UTF-8";
            LC_TELEPHONE = "da_DK.UTF-8";
            LC_TIME = "da_DK.UTF-8";
          };

          services.xserver.enable = true;
          services.displayManager.sddm.enable = true;
          services.desktopManager.plasma6.enable = true;
          services.displayManager.defaultSession = "plasma";

          services.xserver.xkb.layout = "dk";
          console.keyMap = "dk-latin1";

          services.openssh.enable = true;
          services.openssh.settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };

          security.sudo.wheelNeedsPassword = false;

          users.users.Togo-GT = {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "wheel" ];
            description = "Togo-GT";
            packages = with pkgs; [ kdePackages.kate firefox ];
          };

          networking.firewall.allowedTCPPorts = [ 22 80 443 ];
          networking.firewall.allowedUDPPorts = [ 53 ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          system.stateVersion = "25.05";
        }

        # ----------------------------
        # Home Manager integration
        # ----------------------------
        (import "${home-manager}/nixos") {
          pkgs = pkgs;

          configuration = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # ⚡ global backup
            home-manager.backupFileExtension = "backup";

            users.Togo-GT = { pkgs, lib, ... }: {
              home.username = "Togo-GT";
              home.homeDirectory = "/home/Togo-GT";
              home.stateVersion = "25.05";

              # CLI packages
              home.packages = with pkgs; [
                delta lazygit curl ripgrep fzf fd bat jq
                htop bottom duf ncdu tree neofetch
                gparted e2fsprogs
                autojump zsh-autosuggestions zsh-syntax-highlighting
                zoxide eza tldr nano
              ];

              programs.zsh = {
                enable = true;
                shellAliases = {
                  ll = "ls -la";
                  gs = "git status";
                  co = "git checkout";
                  br = "git branch";
                  cm = "git commit";
                  lg = "git log --oneline --graph --decorate --all";
                  nixup = "cd /home/Togo-GT/nixos-btw && sudo nixos-rebuild switch --upgrade --flake .#nixos-btw && home-manager switch --flake .#Togo-GT";
                };
                initContent = ''
                  export EDITOR=nano
                  export VISUAL=nano

                  eval "$(zoxide init zsh)"
                  alias ls="eza --icons --group-directories-first"
                  alias l="eza --icons --group-directories-first -l"
                  alias la="eza --icons --group-directories-first -la"

                  source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
                  source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
                  source ${pkgs.autojump}/share/autojump/autojump.zsh

                  gacp() { git add . && git commit -m "update" && git pull --rebase && git push; }

                  PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '
                '';
              };

              programs.ssh = {
                enable = true;
                enableDefaultConfig = false;
                matchBlocks = {
                  "*" = {
                    extraOptions = {
                      IdentitiesOnly = "yes";
                      ServerAliveInterval = "60";
                      AddKeysToAgent = "yes";
                    };
                  };
                  "github.com" = {
                    user = "git";
                    identityFile = "/home/Togo-GT/.ssh/id_ed25519";
                    identitiesOnly = true;
                  };
                };
              };

              programs.git = {
                enable = true;
                userName = "Togo-GT";
                userEmail = "michael.kaare.nielsen@gmail.com";
                extraConfig = {
                  url."git@github.com:".insteadOf = "https://github.com/";
                  core.sshCommand = "ssh -i /home/Togo-GT/.ssh/id_ed25519";
                };
                aliases = {
                  st = "status";
                  co = "checkout";
                  br = "branch";
                  cm = "commit";
                  lg = "log --oneline --graph --decorate --all";
                };
              };

              programs.vscode = {
                enable = true;
                package = pkgs.vscodium;
              };

              programs.alacritty.enable = true;
            };
          };
        }
      ];
    };
  };
}

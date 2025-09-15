{
  description = "NixOS 25.05 config for nixos-btw with Home Manager ✨";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    username = "Togo-GT";
    hostname = "nixos-btw";
    hashedPassword = "$6$.aOioWFqbvAWRma1$VbHHVMKVQe7hX7tVroZSQt04KJGT2fKSqQmcRRAIKQj0nt1cyd/yubLDRi5j.M9vkTMQgd96dloKJv71Fk1ja0";
  in {
    nixosConfigurations.${hostname} = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        # ----------------------------
        # Hardware config
        # ----------------------------
        ({ lib, config, ... }: {
          boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
          boot.kernelModules = [ "iwlwifi" "kvm-intel" ];
          hardware.enableRedistributableFirmware = true;

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/8f424373-0299-411b-82ba-475f6289a59d";
            fsType = "ext4";
          };

          # UEFI mount point (if using UEFI)
          fileSystems."/boot/efi" = {
            device = "/dev/disk/by-uuid/YOUR_EFI_PARTITION_UUID"; # Replace with your EFI partition UUID
            fsType = "vfat";
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
          # UEFI Support - Uncomment if your system supports UEFI
          boot.loader = {
            # For UEFI systems (uncomment these lines):
            # systemd-boot.enable = true;
            # efi.canTouchEfiVariables = true;
            # efi.efiSysMountPoint = "/boot/efi";

            # For legacy BIOS systems (keep these):
            grub = {
              enable = true;
              device = "/dev/sda";
              useOSProber = true;
              efiSupport = false; # Set to true if using UEFI
            };
            # efi.canTouchEfiVariables = true; # Uncomment if using UEFI
          };

          networking.hostName = hostname;
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

          services.xserver = {
            enable = true;
            layout = "dk";
            xkbVariant = "";
          };

          services.displayManager = {
            sddm = {
              enable = true;
              wayland.enable = true;
            };
            defaultSession = "plasma";
          };

          services.desktopManager.plasma6.enable = true;

          console.keyMap = "dk-latin1";

          services.openssh = {
            enable = true;
            settings = {
              PermitRootLogin = "no";
              PasswordAuthentication = false;
            };
          };

          security.sudo.wheelNeedsPassword = false;

          services.printing.enable = true;
          security.rtkit.enable = true;

          services.pipewire = {
            enable = true;
            alsa = {
              enable = true;
              support32Bit = true;
            };
            pulse.enable = true;
            jack.enable = true;
          };

          programs.ssh.startAgent = true;

          users.users.${username} = {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "wheel" "audio" "video" ];
            description = username;
            hashedPassword = hashedPassword;
            packages = with pkgs; [
              kdePackages.kate
              firefox
              htop
              neovim
              wget
              git

              # Additional useful packages
              bat # Better cat
              eza # Better ls
              fzf # Fuzzy finder
              ripgrep # Better grep

              # Development
              nodejs
              python3
              gcc

              # Productivity
              libreoffice
              kdePackages.okular # PDF viewer (Qt6 version)
            ];
          };

          # Create a root user with no password (login via sudo only)
          users.users.root = {
            hashedPassword = "*"; # Disable password login
          };

          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 22 80 443 ];
            allowedUDPPorts = [ 53 ];
          };

          nix = {
            settings.experimental-features = [ "nix-command" "flakes" ];
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
          };

          system.stateVersion = "25.05";
        }

        # ----------------------------
        # Home Manager integration
        # ----------------------------
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = {
              home = {
                username = username;
                homeDirectory = "/home/${username}";
                stateVersion = "25.05";
              };

              programs = {
                bash = {
                  enable = true;
                  initExtra = ''
                    # Custom bash prompt
                    PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

                    # Aliases using the new packages
                    alias cat='bat'
                    alias ls='eza'
                    alias grep='rg'
                  '';
                };
                git = {
                  enable = true;
                  userName = "Togo-GT";
                  userEmail = "your@email.com"; # Update with your email
                  extraConfig = {
                    init.defaultBranch = "main";
                    pull.rebase = false;
                  };
                };
                neovim = {
                  enable = true;
                  defaultEditor = true;
                };
              };

              home.sessionVariables = {
                EDITOR = "nvim";
                VISUAL = "nvim";
                SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
              };

              home.file = {
                # Example: Create a custom .bash_aliases file
                ".bash_aliases".text = ''
                  alias ll='eza -l'
                  alias la='eza -la'
                  alias update='sudo nixos-rebuild switch --flake ~/nixos-config'
                  alias nixup='sudo git add . && git commit -a && git push && sudo nix flake update && sudo nixos-rebuild switch --flake .#nixos-btw --upgrade'
                  alias find='fzf'
                '';
              };
            };
          };
        }

        # ----------------------------
        # Systemd timers/services
        # ----------------------------
        {
          systemd = {
            timers = {
              cleanOldHomeManagerBackups = {
                description = "Clean old Home Manager backup files older than 30 days";
                timerConfig = {
                  OnCalendar = "*-*-* 03:00:00";
                  Persistent = true;
                };
                wantedBy = [ "timers.target" ];
              };

              nix-garbage-collection = {
                description = "Automatic Nix garbage collection";
                timerConfig = {
                  OnCalendar = "weekly";
                  Persistent = true;
                  RandomizedDelaySec = "1h";
                };
                wantedBy = [ "timers.target" ];
              };
            };

            services = {
              cleanOldHomeManagerBackups = {
                description = "Remove Home Manager backups older than 30 days";
                serviceConfig = {
                  Type = "oneshot";
                  User = username;
                  ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /home/${username}/backups/home-manager && find /home/${username}/backups/home-manager -type f -name \"*.backup\" -mtime +30 -delete'";
                };
                wantedBy = [ "multi-user.target" ];
              };

              nix-garbage-collection = {
                description = "Run nix-collect-garbage -d";
                serviceConfig = {
                  Type = "oneshot";
                  ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
                  User = "root";
                };
                wantedBy = [ "multi-user.target" ];
              };
            };
          };
        }
      ];
    };
  };
}

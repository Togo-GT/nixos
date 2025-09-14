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

    # Home Manager module
    hmModule = import "${home-manager}/nixos" { inherit pkgs; };
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
          boot.kernelModules = [ "kvm-intel" ];
          fileSystems."/" = {
            device = "/dev/disk/by-uuid/8f424373-0299-411b-82ba-475f6289a59d";
            fsType = "ext4";
          };
          swapDevices = [ ];
          networking.useDHCP = lib.mkDefault true;
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        })

        # ----------------------------
        # System basics
        # ----------------------------
        {
          boot.loader.grub.enable = true;
          boot.loader.grub.device = "/dev/sda";

          networking.hostName = "nixos-btw";
          networking.networkmanager.enable = true;

          time.timeZone = "Europe/Copenhagen";
          i18n.defaultLocale = "en_DK.UTF-8";
          console.keyMap = "dk-latin1";

          services.xserver.enable = true;
          services.displayManager.sddm.enable = true;
          services.desktopManager.plasma6.enable = true;
          services.displayManager.defaultSession = "plasma";

          services.openssh.enable = true;
          security.sudo.wheelNeedsPassword = false;

          users.users.Togo-GT = {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "wheel" ];
            packages = with pkgs; [ kdePackages.kate firefox ];
          };

          networking.firewall.allowedTCPPorts = [ 22 80 443 ];
          networking.firewall.allowedUDPPorts = [ 53 ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          system.stateVersion = "25.05";
        }

        # ----------------------------
        # Home Manager module
        # ----------------------------
        hmModule
      ];

      # ----------------------------
      # Home Manager configuration
      # ----------------------------
      nixosModules = [
        ({ pkgs, lib, ... }: {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";

          home-manager.users.Togo-GT = { pkgs, lib, ... }: {
            home.username = "Togo-GT";
            home.homeDirectory = "/home/Togo-GT";
            home.stateVersion = "25.05";

            home.packages = with pkgs; [
              delta lazygit curl ripgrep fzf fd bat jq
              htop bottom duf ncdu tree neofetch
              gparted e2fsprogs
              autojump zsh-autosuggestions zsh-syntax-highlighting
              zoxide eza tldr nano
            ];

            # ----------------------------
            # Zsh
            # ----------------------------
            programs.zsh.enable = true;
            programs.zsh.shellAliases = {
              ll = "ls -la";
              gs = "git status";
              co = "git checkout";
              br = "git branch";
              cm = "git commit";
              lg = "git log --oneline --graph --decorate --all";
              nixup = "cd /home/Togo-GT/nixos-btw && sudo nixos-rebuild switch --upgrade --flake .#nixos-btw && home-manager switch --flake .#Togo-GT";
            };
            programs.zsh.initContent = ''
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

            # ----------------------------
            # SSH
            # ----------------------------
            programs.ssh.enable = true;
            programs.ssh.enableAgent = true;

            # ----------------------------
            # Git
            # ----------------------------
            programs.git.enable = true;
            programs.git.userName = "Togo-GT";
            programs.git.userEmail = "michael.kaare.nielsen@gmail.com";
            programs.git.extraConfig = {
              "url.git@github.com:.insteadOf" = "https://github.com/";
              "core.sshCommand" = "ssh -i /home/Togo-GT/.ssh/id_ed25519";
            };
            programs.git.aliases = {
              st = "status";
              co = "checkout";
              br = "branch";
              cm = "commit";
              lg = "log --oneline --graph --decorate --all";
            };

            # ----------------------------
            # VSCode / VSCodium
            # ----------------------------
            programs.vscode.enable = true;
            programs.vscode.package = pkgs.vscodium;
            programs.vscode.profiles.default = {
              userSettings = {
                "editor.fontSize" = 14;
                "window.zoomLevel" = 1;
                "git.useForcePushWithLease" = true;
              };
              extensions = with pkgs.vscode-extensions; [
                ms-python.python
                eamodio.gitlens
                vscodevim.vim
                ms-toolsai.jupyter
              ];
            };

            # ----------------------------
            # Alacritty
            # ----------------------------
            programs.alacritty.enable = true;
            home.file.".config/alacritty/alacritty.yml".text = ''
              window:
                padding: { x: 8, y: 8 }
                dynamic_title: true
              font:
                normal:
                  family: "Monospace"
                  size: 12.0
              scrolling:
                history: 20000
                multiplier: 3
              cursor:
                style: Block
                blink: true
              live_config_reload: true
              colors:
                primary:
                  background: '0x1d1f21'
                  foreground: '0xc5c8c6'
                cursor:
                  text: '0x1d1f21'
                  cursor: '0xc5c8c6'
            '';

            # ----------------------------
            # Tmux
            # ----------------------------
            home.file.".tmux.conf".text = ''
              set -g mouse on
              setw -g mode-keys vi
              bind r source-file ~/.tmux.conf \; display "Config reloaded!"
              set -g prefix C-a
              unbind C-b
              bind C-a send-prefix
              set -g status-bg colour234
              set -g status-fg colour136
              set -g history-limit 10000
              set -g renumber-windows on
            '';

            # ----------------------------
            # Environment variables
            # ----------------------------
            home.sessionVariables = {
              LANG = "en_DK.UTF-8";
              LC_ALL = "en_DK.UTF-8";
              PAGER = "less";
              MANPAGER = "less";
              GIT_SSH_COMMAND = "ssh -i /home/Togo-GT/.ssh/id_ed25519";
            };
          };
        })
      ];
    };
  };
}

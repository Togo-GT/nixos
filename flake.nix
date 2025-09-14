# ----------------------------
# Home Manager config inline
# ----------------------------
home-manager.nixosModules.home-manager
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  # ⚡ Tilføj backupFileExtension her globalt
  home-manager.backupFileExtension = "backup";

  home-manager.users.Togo-GT = { pkgs, lib, ... }: {
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
  };
}

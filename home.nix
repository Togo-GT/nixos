{ pkgs, lib, ... }:

let
  # ----------------------------
  # Shell aliases
  # ----------------------------
  commonAliases = {
    ll     = "ls -la";
    gs     = "git status";
    co     = "git checkout";
    br     = "git branch";
    cm     = "git commit";
    lg     = "git log --oneline --graph --decorate --all";
    nixup  = "cd /home/Togo-GT/nixos-btw && sudo nixos-rebuild switch --upgrade --flake /home/Togo-GT/nixos-btw#nixos-btw && home-manager switch --flake /home/Togo-GT/nixos-btw#Togo-GT";

    fz     = "fzf";
    rg     = "ripgrep";
    htop   = "htop";
    tree   = "tree";
    duf    = "duf";
    bottom = "btm";
  };

  # ----------------------------
  # CLI Packages
  # ----------------------------
  cliPackages = with pkgs; [
    delta lazygit curl ripgrep fzf fd bat jq
    htop bottom duf ncdu tree neofetch
    gparted e2fsprogs
    autojump zsh-autosuggestions zsh-syntax-highlighting
    zoxide eza tldr
    nano
  ];
in
{
  home.username = "Togo-GT";
  home.homeDirectory = "/home/Togo-GT";
  home.stateVersion = "25.05";

  # ----------------------------
  # Packages
  # ----------------------------
  home.packages = cliPackages;

  # ----------------------------
  # Zsh Configuration
  # ----------------------------
  programs.zsh = {
    enable = true;
    shellAliases = commonAliases;
    initContent = ''
      export EDITOR=nano
      export VISUAL=nano

      # Better navigation
      eval "$(zoxide init zsh)"
      alias ls="eza --icons --group-directories-first"
      alias l="eza --icons --group-directories-first -l"
      alias la="eza --icons --group-directories-first -la"

      # Load plugins from Nix
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.autojump}/share/autojump/autojump.zsh

      # Start SSH agent if not running
      if [ -z "$SSH_AUTH_SOCK" ]; then
        eval "$(ssh-agent -s)" > /dev/null
      fi
      ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519 2>/dev/null

      # Git add, commit, pull, push function
      gacp() { git add . && git commit -m "update" && git pull --rebase && git push; }

      # Minimal prompt
      PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '
    '';
  };

  # ----------------------------
  # SSH Configuration
  # ----------------------------
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
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };
    };
  };

  # ----------------------------
  # Git Configuration
  # ----------------------------
  programs.git = {
    enable = true;
    userName = "Togo-GT";
    userEmail = "michael.kaare.nielsen@gmail.com";
    extraConfig = {
      url."git@github.com:".insteadOf = "https://github.com/";
      core.sshCommand = "ssh -i ~/.ssh/id_ed25519";
    };
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      cm = "commit";
      lg = "log --oneline --graph --decorate --all";
    };
  };

  # ----------------------------
  # Generate SSH key if missing
  # ----------------------------
  home.activation.setupSSHKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SSH_KEY="$HOME/.ssh/id_ed25519"
    if [ ! -f "$SSH_KEY" ]; then
      echo "Generating SSH key for GitHub..."
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "michael.kaare.nielsen@gmail.com" -f "$SSH_KEY" -N ""
      ssh-add "$SSH_KEY" 2>/dev/null || true
      echo "SSH key generated at $SSH_KEY.pub"
      echo "Please add this key to your GitHub account:"
      cat "$SSH_KEY.pub"
    fi
  '';

  # ----------------------------
  # Start SSH agent on graphical login (Plasma/KDE)
  # ----------------------------
  home.file."~/.xprofile".text = ''
    if [ -z "$SSH_AUTH_SOCK" ]; then
      eval "$(ssh-agent -s)" > /dev/null
    fi
    ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519 2>/dev/null
  '';

  # ----------------------------
  # VSCode Configuration
  # ----------------------------
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default = {
      userSettings = {
        "editor.fontSize" = 14;
        "window.zoomLevel" = 1;
        "git.useForcePushWithLease" = true;
      };
      extensions = [
        pkgs.vscode-extensions.ms-python.python
        pkgs.vscode-extensions.eamodio.gitlens
        pkgs.vscode-extensions.vscodevim.vim
        pkgs.vscode-extensions.ms-toolsai.jupyter
      ];
    };
  };

  # ----------------------------
  # Alacritty terminal
  # ----------------------------
  programs.alacritty.enable = true;
  home.file.".config/alacritty/alacritty.yml".text = ''
    window:
      padding:
        x: 8
        y: 8
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
  # Tmux configuration
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
  # Session variables
  # ----------------------------
  home.sessionVariables = {
    LANG        = "en_DK.UTF-8";
    LC_ALL      = "en_DK.UTF-8";
    PAGER       = "less";
    MANPAGER    = "less";
    GIT_SSH_COMMAND = "ssh -i ~/.ssh/id_ed25519";
  };
}

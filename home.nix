{  pkgs, lib, ... }:

let
  # ----------------------------
  # Shell aliases
  # ----------------------------
  commonAliases = {
    ll    = "ls -la";
    gs    = "git status";
    co    = "git checkout";
    br    = "git branch";
    cm    = "git commit";
    lg    = "git log --oneline --graph --decorate --all";
    nixup = "sudo nixos-rebuild switch --upgrade --flake /home/gt/nixos#nixos-btw";
    fz    = "fzf";
    rg    = "ripgrep";
    htop  = "htop";
    tree  = "tree";
    duf   = "duf";
    bottom = "btm";
    add = "add .";
  };

  # ----------------------------
  # CLI Packages
  # ----------------------------
  cliPackages = with pkgs; [
    # Dev tools
    delta lazygit curl ripgrep fzf fd bat jq

    # System monitoring
    htop bottom duf ncdu tree neofetch

    # Disk utilities
    gparted e2fsprogs

    # Shell enhancements
    autojump zsh-autosuggestions zsh-syntax-highlighting
    zoxide eza tldr

    # Editors
    nano
  ];
in
{
  home.username = "gt";
  home.homeDirectory = "/home/gt";
  home.stateVersion = "25.05";

  # ----------------------------
  # Packages
  # ----------------------------
  home.packages = cliPackages;

  # ----------------------------
  # Zsh Configuration (Primary Shell)
  # ----------------------------
  programs.zsh = {
    enable = true;
    shellAliases = commonAliases;
    initContent = ''
      # Editor - nano som standard
      export EDITOR=nano
      export VISUAL=nano

      # Bedre navigation
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

      # Add SSH key if not already added
      ssh-add -l > /dev/null || ssh-add ~/.ssh/id_ed25519 2>/dev/null

      # Git Power Dashboard
      function git_power_dashboard() {
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n $branch ]]; then
          local ahead behind staged unstaged untracked
          ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
          behind=$(git rev-list --count HEAD..@{u} 2>/dev/null || echo 0)
          staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
          unstaged=$(git diff --name-only 2>/dev/null | wc -l)
          untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l)

          local out="" in="" s="" u="" t=""
          [[ $ahead -gt 0 ]] && out="%F{green}↑$ahead%f"
          [[ $behind -gt 0 ]] && in="%F{red}↓$behind%f"
          [[ $staged -gt 0 ]] && s="%F{blue}+$staged%f"
          [[ $unstaged -gt 0 ]] && u="%F{yellow}~$unstaged%f"
          [[ $untracked -gt 0 ]] && t="%F{magenta}?$untracked%f"

          echo "%F{cyan}$branch%f $out$in$s$u$t"
        fi
      }

      # Powerlevel10k prompt hvis installeret
      if [[ -f ~/.p10k.zsh ]]; then
        source ~/.p10k.zsh
        typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time background_jobs git_power_dashboard)
      fi
    '';
  };

  # ----------------------------
  # SSH Configuration (FIXED)
  # ----------------------------
  programs.ssh = {
    enable = true;
    # Deaktiver automatisk standardkonfiguration
    enableDefaultConfig = false;

    # Manuel konfiguration af standardindstillinger
    matchBlocks = {
      # Standardindstillinger for alle hosts
      "*" = {
        # Tilføj de standardindstillinger du ønsker at beholde
        extraOptions = {
          IdentitiesOnly = "yes";
          ServerAliveInterval = "60";
          AddKeysToAgent = "yes";
        };
      };

      # Github-specifik konfiguration
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
    # Use SSH instead of HTTPS for GitHub
    extraConfig = {
      url."git@github.com:".insteadOf = "https://github.com/";
      # Use SSH for authentication instead of HTTPS tokens
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
  # Generate SSH key if it doesn't exist (FIXED)
  # ----------------------------
  home.activation.setupSSHKey = lib.hm.dag.entryAfter ["writeBoundary"] ''
    SSH_KEY="/home/gt/.ssh/id_ed25519"
    if [ ! -f "$SSH_KEY" ]; then
      echo "Generating SSH key for GitHub..."
      ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "michael.kaare.nielsen@gmail.com" -f "$SSH_KEY" -N ""
      echo "SSH key generated at $SSH_KEY.pub"
      echo "Please add this key to your GitHub account:"
      cat "$SSH_KEY.pub"
    fi
  '';

  # ----------------------------
  # VSCode Configuration (UPDATED)
  # ----------------------------
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    # Updated to use the new profile structure
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
  # Terminal emulator
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
  # Tmux Configuration
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
    LANG   = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    PAGER  = "less";
    MANPAGER = "less";
    GIT_SSH_COMMAND = "ssh -i ~/.ssh/id_ed25519"; # Ensure Git uses the correct SSH key
  };
}

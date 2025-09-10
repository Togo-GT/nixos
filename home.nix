{ config, pkgs, ... }:

let
  terminalAliases = {
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
  };

  cliPackages = with pkgs; [
    delta lazygit htop curl gparted e2fsprogs ripgrep fzf fd bat jq ncdu tree neofetch
    autojump zsh-autosuggestions zsh-syntax-highlighting
  ];
in
{
  home.username = "gt";
  home.homeDirectory = "/home/gt";
  home.stateVersion = "25.05";

  # ----------------------------
  # 🐚 Zsh
  # ----------------------------
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      theme = "powerlevel10k/powerlevel10k"; # korrekt sti
      plugins = [ "git" "z" "sudo" ];        # øvrige plugins loades manuelt
    };

    initContent = ''
      # Aliases
      alias ll="ls -lah"
      alias gs="git status"
      alias co="git checkout"
      alias br="git branch"
      alias cm="git commit"
      alias lg="git log --oneline --graph --decorate --all"
      alias fz="fzf"
      alias rg="ripgrep"
      alias htop="htop"
      alias tree="tree"
      alias nixup="sudo nixos-rebuild switch --upgrade --flake /home/gt/nixos#nixos-btw"

      export EDITOR=nvim
      export VISUAL=nvim

      # Load plugins fra Nix
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      source ${pkgs.autojump}/share/autojump/autojump.zsh

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

      # Powerlevel10k right prompt
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time background_jobs git_power_dashboard)
      [[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
    '';
  };

  # ----------------------------
  # Bash aliaser
  # ----------------------------
  programs.bash = {
    enable = true;
    shellAliases = terminalAliases;
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
        family: Monospace
        size: 12.0
    scrolling:
      history: 10000
      multiplier: 3
    cursor:
      style: Block
      blink: true
    colors:
      primary:
        background: '0x1d1f21'
        foreground: '0xc5c8c6'
  '';

  # ----------------------------
  # Editors
  # ----------------------------
  programs.vim.enable = true;
  programs.neovim.enable = true;
  home.file.".config/nvim/init.vim".text = ''
    set number
    syntax on
    filetype plugin indent on
    set tabstop=2
    set shiftwidth=2
    set expandtab
    set clipboard=unnamedplus
  '';

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      ms-python.python
      eamodio.gitlens
      vscodevim.vim
      ms-toolsai.jupyter
    ];
  };

  # ----------------------------
  # Git config
  # ----------------------------
  programs.git.enable = true;
  home.file.".gitconfig".text = ''
    [user]
      name = "Togo-GT"
      email = "michael.kaare.nielsen@gmail.com"
    [core]
      editor = nvim
    [alias]
      st = status
      co = checkout
      br = branch
      cm = commit
      lg = log --oneline --graph --decorate --all
    [credential]
      helper = cache --timeout=3600
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
  '';

  home.packages = cliPackages;

  home.sessionVariables = {
    LANG   = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
}

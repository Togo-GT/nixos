{ pkgs, ... }:

let
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
  # 🐚 Zsh Configuration
  # ----------------------------
  programs.zsh = {
    enable = true;
    shellAliases = commonAliases;
    initExtra = ''
      export EDITOR=nano
      export VISUAL=nano

      # Load plugins from Nix
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
  # Bash Configuration
  # ----------------------------
  programs.bash = {
    enable = true;
    shellAliases = commonAliases;
  };

  # Resten af din konfiguration forbliver uændret...
  # [Terminal, Editors, Git, Tmux osv.]
}

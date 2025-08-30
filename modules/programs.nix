{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------------
  # 🌐 Browsers & VCS
  # -----------------------------------------------------------------------------
  programs.firefox.enable = true;    # 🌍 Web browser
  programs.git = {
    enable = true;                   # 🔧 Git CLI
    config = {
      user.name = "Togo-GT";
      user.email = "michael.kaare.nielsen@gmail.com";
      init.defaultBranch = "main";
    };
  };

  # -----------------------------------------------------------------------------
  # 📦 Unfree packages
  # -----------------------------------------------------------------------------
  nixpkgs.config.allowUnfree = true; # tillad fx Firefox non-free codecs

  # -----------------------------------------------------------------------------
  # 🖥️ System packages – essentials
  # -----------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    wget                 # 🌐 download tool
    git                     # 🔧 version control
    gparted
    parted
    e2fsprogs
    htop                 # 📊 system monitor
    neovim            # ✏️ terminal editor
    ripgrep            # 🔍 file search
    vlc                    # 🎬 media player
    pipewire         # 🎧 audio server
    #vscode   # official Microsoft VS Code
    # or
    vscodium # open-source build



  ];


  # -----------------------------------------------------------------------------
  # 🔊 Services
  # -----------------------------------------------------------------------------
  # services.pipewire.enable = true;
  # services.pipewire.support32Bit = true; # ekstra til kompatibilitet
}

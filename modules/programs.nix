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
    #git                     # 🔧 version control
    htop                 # 📊 system monitor
    neovim            # ✏️ terminal editor
    ripgrep            # 🔍 file search
    vlc                    # 🎬 media player
    pipewire         # 🎧 audio server
  ];

  # -----------------------------------------------------------------------------
  # 🔊 Services
  # -----------------------------------------------------------------------------
  # services.pipewire.enable = true;
  # services.pipewire.support32Bit = true; # ekstra til kompatibilitet
}

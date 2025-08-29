{ config, pkgs, ... }:
{
  # Programs 🛠️
  programs.firefox.enable = true;          # Firefox 🌐
  nixpkgs.config.allowUnfree = true;       # Tillad unfree pakker ⚖️

  environment.systemPackages = with pkgs; [
      wget                           # Command-line downloader 📥
      git                            # Version control system 🔧
      pipewire                       # PipeWire system package 🔊
      qt5.qtbase                      # Qt5 base library 📚
      qt5.qtmultimedia                # Qt5 multimedia 🎞️
      pkgs.python313Full             # Python 3.13.7 🐍
      pkgs.python313Packages.pelican  # Pelican static site generator 🌐✍️
      )
  ];
}

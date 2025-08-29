{ config, pkgs, ... }:

{
  # -----------------------------------------------------------------------------
  # 📦 Imports – modulær konfiguration
  # -----------------------------------------------------------------------------
  imports = [
    ./hardware-configuration.nix    # 🖥️ Hardware opsætning
    ./modules/bootloader.nix        # 🚀 Bootloader
    ./modules/locale.nix            # 🌍 Sprog & tid
    ./modules/users.nix             # 👤 Brugere & grupper
    ./modules/networking.nix        # 🌐 Netværk
    ./modules/firewall.nix          # 🔥 Firewall
    ./modules/graphical.nix         # 💻 Grafisk miljø
    ./modules/sound.nix             # 🔊 Lyd & PipeWire
    ./modules/programs.nix          # 📦 Diverse programmer
    ./modules/git.nix               # 🔧 Git konfiguration
    ./modules/python.nix            # 🐍 Python
    ./modules/qt.nix                # 🖱️ Qt biblioteker
    ./modules/kde.nix               # ✨ KDE apps
    ./modules/services.nix          # 🛠️ Services
    ./modules/containers.nix        # 📦 Container opsætning
    ./modules/garbage-upgrade.nix   # ♻️ Automatic Garbage Collection & System Upgrade
  ];

  # -----------------------------------------------------------------------------
  # 🕹️ System version
  # -----------------------------------------------------------------------------
  system.stateVersion = "25.05";    # 🔑 NixOS version – vigtig for opgraderinger
}
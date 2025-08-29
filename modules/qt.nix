{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    qt6.qtbase        # 🖥️ Qt base libraries
    qt6.qtmultimedia  # 🎵 Multimedia support
    qt6.qttools       # 🛠 Extra tools & dev utilities
  ];
}

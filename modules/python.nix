{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313Full                  # 🐍 Python 3.13
    python313Packages.pelican      # 📝 Static site generator
  ];
}

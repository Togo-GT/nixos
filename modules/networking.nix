{ config, ... }:
{
  # Networking 🌐
  networking.hostName              = "nixos"; # Hostname 💻
  networking.networkmanager.enable = true;   # NetworkManager 🟢
}

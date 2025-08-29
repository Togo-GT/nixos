{ config, ... }:
{
  # Firewall 🔥🛡️
  networking.firewall.enable          = true;           # Aktivér firewall 🟢
  networking.firewall.allowedTCPPorts = [ 22 9000 8080 ]; # SSH + Portainer + Heimdall 🌐
  networking.firewall.allowedUDPPorts = [ ];            # Ingen UDP som standard ❌
}

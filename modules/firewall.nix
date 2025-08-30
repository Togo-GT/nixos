{ config, ... }:
{
  # Firewall 🔥🛡️
  networking.firewall.enable          = true;           # Aktivér firewall 🟢
  networking.firewall.allowedTCPPorts = [ 22 9000 8080 11434 ]; # SSH + Portainer + Heimdall + Ollama 🌐
  networking.firewall.allowedUDPPorts = [ ];            # Ingen UDP som standard ❌
}

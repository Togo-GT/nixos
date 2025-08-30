{ config, pkgs, ... }:

{
  # Containers & Docker 🐳
  virtualisation.docker.enable = true;  # Aktiver Docker runtime 🟢
  virtualisation.oci-containers = {
    backend = "docker";  # Docker backend 🐳

    # Portainer ⚙️ – web UI til Docker
    containers.portainer = {
      image   = "portainer/portainer-ce:latest";
      ports   = [ "9000:9000" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock"
        "/var/lib/portainer:/data"
      ];
      autoStart = true;
    };

    # Watchtower ⏰ – auto-update Docker containers
    containers.watchtower = {
      image   = "containrrr/watchtower:latest";
      volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
      cmd     = [ "--cleanup" "--interval" "300" "portainer" ];  # Ingen komma efter sidste element
      autoStart = true;
    };

    # Heimdall 🛡️ – dashboard til apps
    containers.heimdall = {
      image   = "linuxserver/heimdall:latest";
      ports   = [ "8080:80" ];
      volumes = [ "/opt/heimdall/config:/config" ];
      environment = {
        PUID = "1000";
        PGID = "100";
      };
      autoStart = true;
    };
  };

  # Systemd service til Ollama 🤖
  # systemd.services.ollama = {
  #  description = "Ollama LLM Docker Service 🤖";
  #  wants = [ "docker.service" ];
  #  after = [ "docker.service" ];
  #  serviceConfig = {
  #    ExecStart = "${pkgs.docker}/bin/docker run --rm -p 11434:11434 ollama/ollama:latest";
  #    Restart = "always";      # Genstart ved fejl 🔁
  #    RestartSec = 10;         # Vent 10 sekunder før restart ⏱️
  #  };
  # };
}

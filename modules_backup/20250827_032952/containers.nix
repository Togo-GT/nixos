{ config, ... }:
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
          cmd     = [ "--cleanup" "--interval" "300" "portainer" ];
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
}

{ config, pkgs, ... }:

let
  # Definer Ollama binær som en pakke
  ollama = pkgs.stdenv.mkDerivation {
    pname = "ollama";
    version = "latest";
    src = null; # Vi henter manuelt
    installPhase = ''
      mkdir -p $out/bin
      # Antag at du har lagt binæren i /opt/ollama/ollama
      cp /opt/ollama/ollama $out/bin/
      chmod +x $out/bin/ollama
    '';
  };
in
{
  # Tilføj Ollama til systemets pakker
  environment.systemPackages = with pkgs; [
    ollama
  ];

  # Systemd service til Ollama
  systemd.services.ollama = {
    description = "Ollama AI Server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/opt/ollama/ollama serve";
      Restart = "always";
      User = "root"; # eller en specifik bruger
      WorkingDirectory = "/opt/ollama";
    };
  };

  # Firewall port hvis du vil tilgå Ollama eksternt
  networking.firewall.allowedTCPPorts = [ 11434 ];
}

{ config, pkgs, lib, ... }:

{
  systemd.services.autoWifi = {
    description = "Auto-connect to Wi-Fi on boot";
    after = [ "network.target" "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    serviceConfig.ExecStart = ''
      nmcli device wifi connect "YOUR_SSID" password "$(cat /home/Togo-GT/.password)" || true
    '';
  };
}


{ config, pkgs, ... }:
{
  # Sound 🔊
  services.pulseaudio.enable = false; # Pulseaudio ❌
  security.rtkit.enable       = true; # Realtime scheduling ⏱️
  services.pipewire = {
      enable          = true;   # PipeWire 🟢
      alsa.enable     = true;   # ALSA 🔊
      alsa.support32Bit = true; # 32-bit 🕹️
      pulse.enable    = true;   # Pulseaudio kompatibilitet 🔄
  };
}

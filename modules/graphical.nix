{ config, pkgs, lib, ... }:

{
  # ---------------------------------------------------------------------------
  # X11 & Display Manager 🖥️
  # ---------------------------------------------------------------------------
  services.xserver.enable = true;                       # Enable X11
  services.xserver.displayManager.lightdm.enable = true; # Login screen

  # ---------------------------------------------------------------------------
  # Desktop Environments 💻✨
  # ---------------------------------------------------------------------------
  services.desktopManager.plasma6.enable = true; # Plasma 6 (Qt6-based) ✨
  services.xserver.desktopManager.xfce.enable = true; # XFCE 💻

  # ---------------------------------------------------------------------------
  # Keyboard Layout ⌨️
  # ---------------------------------------------------------------------------
  services.xserver.xkb = {
    layout = "dk";   # Danish layout 🇩🇰
    variant = "";    # Default variant
  };

  # ---------------------------------------------------------------------------
  # PipeWire Sound Server 🔊
  # ---------------------------------------------------------------------------
  services.pipewire = {
    enable = true;   # Enable PipeWire
    alsa.enable = true;   # ALSA support
    pulse.enable = true;  # PulseAudio support
    jack.enable = true;   # JACK support
  };

  # ---------------------------------------------------------------------------
  # Environment Variables 🌱
  # ---------------------------------------------------------------------------
  environment.variables = {
    LD_LIBRARY_PATH = lib.mkForce "${pkgs.pipewire}/lib:${pkgs.pipewire}/lib64"; 
    # Force PipeWire libraries to avoid conflicts 🔧
  };
}

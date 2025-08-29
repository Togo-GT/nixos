{ config, ... }:
{
  # Graphical Environment 🖥️
  services.xserver.enable                     = true;             # X11 🟢
  services.xserver.displayManager.lightdm.enable = true;          # LightDM 🔑
  services.xserver.desktopManager.xfce.enable    = true;          # XFCE 💻
  services.xserver.xkb = { layout = "dk"; variant = ""; };        # DK keyboard ⌨️
  console.keyMap = "dk-latin1";                                     # Console keymap 🖥️
}

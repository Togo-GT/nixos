{ config, ... }:
{
  # ---------------------------
  # Time & Locale ⏰🌍
  # ---------------------------
  time.timeZone      = "Europe/Copenhagen";   # Tidzone 🕒

  # System & UI language → English
  i18n.defaultLocale = "en_US.UTF-8";         # OS sprog 🌐

  # Keep Danish formatting for dates, currency, etc.
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "da_DK.UTF-8";    # Adresse 🏠
    LC_IDENTIFICATION = "da_DK.UTF-8";    # Identifikation 🆔
    LC_MEASUREMENT    = "da_DK.UTF-8";    # Målesystem 📏
    LC_MONETARY       = "da_DK.UTF-8";    # Valuta 💰
    LC_NAME           = "da_DK.UTF-8";    # Navneformat 📝
    LC_NUMERIC        = "da_DK.UTF-8";    # Talformat 🔢
    LC_PAPER          = "da_DK.UTF-8";    # Papirstørrelse 📄
    LC_TELEPHONE      = "da_DK.UTF-8";    # Telefonformat 📞
    LC_TIME           = "da_DK.UTF-8";    # Tidsformat ⏱️
  };

  # ---------------------------
  # Keyboard ⌨️
  # ---------------------------
  console.keyMap = "dk";                # Dansk tastatur i TTY
  services.xserver.xkb.layout = "dk";   # Dansk tastatur i X11/Wayland
}


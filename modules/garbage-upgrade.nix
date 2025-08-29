{ config, pkgs, lib, ... }:

{
  # -----------------------------------------------------------------------------
  # ♻️ Garbage Collection & System Upgrade
  # -----------------------------------------------------------------------------

  # 🔄 Automatisk systemopgradering
  system.autoUpgrade.enable      = true;                   # ✅ Aktiver automatisk opgradering
  system.autoUpgrade.channel     = "nixos-25.05";          # 🌐 Opgrader fra denne kanal
  system.autoUpgrade.allowReboot = false;                  # 🚫 Undgå automatisk genstart

  # 🗑️ Nix Garbage Collection – automatisk optimering
  nix.settings = {
    auto-optimise-store = true;                            # 📦 Optimer Nix store automatisk
    # max-free = "15%"; # 💾 Denne kan tilføjes hvis du vil køre GC når lager er fyldt
  };

  # ⏱️ Timer til periodisk garbage collection
  systemd.timers.nix-gc = {
    description = "♻️ Kør Nix garbage collection ugentligt"; 
    timerConfig = {
      OnCalendar = "weekly";                               # 📆 Kør ugentligt
    };
    wantedBy = [ "timers.target" ];                        # ⏰ Tilknyt timer til systemd
  };
}

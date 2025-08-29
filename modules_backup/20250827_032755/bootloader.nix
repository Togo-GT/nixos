{ config, ... }:
{
  # Bootloader 🚀
  boot.loader.systemd-boot.enable      = true;  # Brug systemd-boot 🟢
  boot.loader.efi.canTouchEfiVariables = true;  # Tillad ændring af EFI variabler ⚡
}

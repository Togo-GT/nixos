{ config, pkgs, ... }:
{
  # User Accounts 👤
  users.users.gt = {
      isNormalUser  = true;                               # Normal bruger ✅
      description   = "GT 😎";                            # Beskrivelse
      extraGroups   = [ "networkmanager" "wheel" "docker" ]; # Net, sudo, Docker 🌐🔑🐳
      packages      = with pkgs; [ ];                     # Brugerspecifikke pakker
  };
  services.displayManager.autoLogin.enable = true;  # Auto login 🔓
  services.displayManager.autoLogin.user   = "gt";  # Bruger til auto login 👤
  security.sudo.enable             = true;  # Sudo 🟢
  security.sudo.wheelNeedsPassword = false; # Wheel uden password 🔓
}

{ config, ... }:
{
  # Services ⚙️
  services.printing.enable = true;  # CUPS 🟢
  services.openssh.enable  = true;  # SSH 🔑
  services.openssh.settings = {
      PasswordAuthentication = false; # Kun nøgle-login 🔐
      PermitRootLogin       = "no";   # Deaktiver root ❌
  };
}

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ----------------------------
  # System basics
  # ----------------------------
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos-btw";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Copenhagen";

  i18n.defaultLocale = "en_DK.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  # ----------------------------
  # Desktop Environment
  # ----------------------------
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkb.layout = "dk";
  console.keyMap = "dk-latin1";

  # ----------------------------
  # Security
  # ----------------------------
  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "no";
    PasswordAuthentication = false;
  };

  security.sudo.wheelNeedsPassword = false;

  # ----------------------------
  # Audio
  # ----------------------------
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire.enable = true;
  services.pipewire.alsa.enable = true;
  services.pipewire.alsa.support32Bit = true;
  services.pipewire.pulse.enable = true;

  # ----------------------------
  # User
  # ----------------------------
  users.users.Togo-GT = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    description = "Togo-GT";
    packages = with pkgs; [ kdePackages.kate firefox ];
  };

  # ----------------------------
  # Firewall
  # ----------------------------
  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 53 ];

  # ----------------------------
  # Nix / Flakes
  # ----------------------------
  nix = {
    package = pkgs.nixVersions.latest;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };

  system.stateVersion = "25.05";
}

#!/usr/bin/env bash
set -e

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------
NIXOS_DIR="/etc/nixos"
MODULES_DIR="$NIXOS_DIR/modules"
BACKUP_DIR="$NIXOS_DIR/modules_backup"

mkdir -p "$BACKUP_DIR"

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
list_backups() {
    echo "Available backups:"
    ls -1dt "$BACKUP_DIR"/* | nl
}

rollback_backup() {
    local choice
    list_backups
    read -rp "Enter the number of the backup to restore: " choice
    local selected
    selected=$(ls -1dt "$BACKUP_DIR"/* | sed -n "${choice}p")
    if [ -z "$selected" ]; then
        echo "Invalid selection!"
        exit 1
    fi

    # Backup before rollback
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    PRE_ROLLBACK="$BACKUP_DIR/$TIMESTAMP-pre-rollback"
    echo "Backing up current modules to $PRE_ROLLBACK"
    cp -r "$MODULES_DIR"/. "$PRE_ROLLBACK"/

    echo "Restoring backup: $selected"
    rm -rf "$MODULES_DIR"/*
    cp -r "$selected"/. "$MODULES_DIR"/
    echo "Rollback completed ✅"
}

# -----------------------------------------------------------------------------
# Ask user if they want to overwrite old modules
# -----------------------------------------------------------------------------
if [ -d "$MODULES_DIR" ] && [ "$(ls -A $MODULES_DIR)" ]; then
    read -rp "Modules already exist. Overwrite and backup old ones? [y/N]: " overwrite
    overwrite=${overwrite:-N}
    if [[ "$overwrite" =~ ^[Yy]$ ]]; then
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        BACKUP="$BACKUP_DIR/$TIMESTAMP"
        echo "Backing up current modules to $BACKUP"
        cp -r "$MODULES_DIR"/. "$BACKUP"/
        echo "Old modules backed up ✅"
    else
        echo "Exiting without changes."
        exit 0
    fi
fi

# -----------------------------------------------------------------------------
# Rotate backups (max 4)
# -----------------------------------------------------------------------------
mapfile -t existing < <(ls -1dt "$BACKUP_DIR"/* 2>/dev/null)
if [ "${#existing[@]}" -ge 4 ]; then
    oldest="${existing[-1]}"
    echo "Deleting oldest backup: $oldest"
    rm -rf "$oldest"
fi

# -----------------------------------------------------------------------------
# Declare modules with formatting, emojis, and comments
# -----------------------------------------------------------------------------
declare -A modules

modules=(
"bootloader.nix" '{ config, ... }:
{
  # Bootloader 🚀
  boot.loader.systemd-boot.enable      = true;  # Brug systemd-boot 🟢
  boot.loader.efi.canTouchEfiVariables = true;  # Tillad ændring af EFI variabler ⚡
}'

"locale.nix" '{ config, ... }:
{
  # Time & Locale ⏰🌍
  time.timeZone      = "Europe/Copenhagen";  # Tidzone 🕒
  i18n.defaultLocale = "da_DK.UTF-8";        # Standard locale 🌐
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
}'

"users.nix" '{ config, pkgs, ... }:
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
}'

"networking.nix" '{ config, ... }:
{
  # Networking 🌐
  networking.hostName              = "nixos"; # Hostname 💻
  networking.networkmanager.enable = true;   # NetworkManager 🟢
}'

"firewall.nix" '{ config, ... }:
{
  # Firewall 🔥🛡️
  networking.firewall.enable          = true;           # Aktivér firewall 🟢
  networking.firewall.allowedTCPPorts = [ 22 9000 8080 ]; # SSH + Portainer + Heimdall 🌐
  networking.firewall.allowedUDPPorts = [ ];            # Ingen UDP som standard ❌
}'

"graphical.nix" '{ config, ... }:
{
  # Graphical Environment 🖥️
  services.xserver.enable                     = true;             # X11 🟢
  services.xserver.displayManager.lightdm.enable = true;          # LightDM 🔑
  services.xserver.desktopManager.xfce.enable    = true;          # XFCE 💻
  services.xserver.xkb = { layout = "dk"; variant = ""; };        # DK keyboard ⌨️
  console.keyMap = "dk-latin1";                                     # Console keymap 🖥️
}'

"sound.nix" '{ config, pkgs, ... }:
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
}'

"programs.nix" '{ config, pkgs, ... }:
{
  # Programs 🛠️
  programs.firefox.enable = true;          # Firefox 🌐
  nixpkgs.config.allowUnfree = true;       # Tillad unfree pakker ⚖️

  environment.systemPackages = with pkgs; [
      wget                           # Command-line downloader 📥
      git                            # Version control system 🔧
      pipewire                       # PipeWire system package 🔊
      qt5.qtbase                      # Qt5 base library 📚
      qt5.qtmultimedia                # Qt5 multimedia 🎞️
      pkgs.python313Full             # Python 3.13.7 🐍
      pkgs.python313Packages.pelican  # Pelican static site generator 🌐✍️

  ];
}'

"services.nix" '{ config, ... }:
{
  # Services ⚙️
  services.printing.enable = true;  # CUPS 🟢
  services.openssh.enable  = true;  # SSH 🔑
  services.openssh.settings = {
      PasswordAuthentication = false; # Kun nøgle-login 🔐
      PermitRootLogin       = "no";   # Deaktiver root ❌
  };
}'

"containers.nix" '{ config, ... }:
{
  # Containers & Docker 🐳
  virtualisation.docker.enable = true;  # Aktiver Docker runtime 🟢
  virtualisation.oci-containers = {
      backend = "docker";  # Docker backend 🐳

      # Portainer ⚙️ – web UI til Docker
      containers.portainer = {
          image   = "portainer/portainer-ce:latest";
          ports   = [ "9000:9000" ];
          volumes = [
              "/var/run/docker.sock:/var/run/docker.sock"
              "/var/lib/portainer:/data"
          ];
          autoStart = true;
      };

      # Watchtower ⏰ – auto-update Docker containers
      containers.watchtower = {
          image   = "containrrr/watchtower:latest";
          volumes = [ "/var/run/docker.sock:/var/run/docker.sock" ];
          cmd     = [ "--cleanup" "--interval" "300" "portainer" ];
          autoStart = true;
      };

      # Heimdall 🛡️ – dashboard til apps
      containers.heimdall = {
          image   = "linuxserver/heimdall:latest";
          ports   = [ "8080:80" ];
          volumes = [ "/opt/heimdall/config:/config" ];
          environment = {
              PUID = "1000";
              PGID = "100";
          };
          autoStart = true;
      };
  };
}'
)

# -----------------------------------------------------------------------------
# Clean modules dir and write new modules
# -----------------------------------------------------------------------------
rm -rf "$MODULES_DIR"/*
mkdir -p "$MODULES_DIR"

for file in "${!modules[@]}"; do
    echo "Creating $MODULES_DIR/$file"
    echo "${modules[$file]}" > "$MODULES_DIR/$file"
done

# -----------------------------------------------------------------------------
# Write configuration.nix
# -----------------------------------------------------------------------------
CONFIG_FILE="$NIXOS_DIR/configuration.nix"
cat > "$CONFIG_FILE" <<'EOF'
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/bootloader.nix
    ./modules/locale.nix
    ./modules/users.nix
    ./modules/networking.nix
    ./modules/firewall.nix
    ./modules/graphical.nix
    ./modules/sound.nix
    ./modules/programs.nix
    ./modules/services.nix
    ./modules/containers.nix
  ];
  system.stateVersion = "25.05";
}
EOF

echo "All module files created with timestamped backup ✅"

# -----------------------------------------------------------------------------
# Ask user if they want rollback
# -----------------------------------------------------------------------------
read -rp "Do you want to rollback to a previous backup? [y/N]: " roll
roll=${roll:-N}
if [[ "$roll" =~ ^[Yy]$ ]]; then
    rollback_backup
fi

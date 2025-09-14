{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix   # 🖥 Hardware scan results
  ];

  # ----------------------------
  # 💻 System Basics
  # ----------------------------
  boot.loader.grub.enable = true;             # 🥧 Enable GRUB
  boot.loader.grub.device = "/dev/sda";       # 💽 GRUB install device
  boot.loader.grub.useOSProber = true;        # 🔍 Detect other OSes

  networking.hostName = "nixos-btw";          # 🌐 Hostname
  networking.networkmanager.enable = true;    # 📶 NetworkManager

  time.timeZone = "Europe/Copenhagen";        # ⏰ Timezone

  # Locale: English system with Danish formatting 🇩🇰
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
  # 🖥 Desktop Environment
  # ----------------------------
  services.xserver.enable = true;              # 🖥 Enable X server
  services.displayManager.sddm.enable = true;  # 🔑 SDDM login manager
  services.desktopManager.plasma6.enable = true; # 🖱 KDE Plasma 6

  services.xserver.xkb = {
    layout = "dk";     # ⌨️ Keyboard layout
    variant = "";
  };
  console.keyMap = "dk-latin1";                # 🖥 Console keyboard

  # ----------------------------
  # 🔒 Security / SSH / sudo
  # ----------------------------
  services.openssh = {
    enable = true;              # 🟢 SSH server
    settings = {
      PermitRootLogin = "no";   # ❌ Disable root login (god praksis)
      PasswordAuthentication = false; # 🔒 Disable password auth (kun nøgler)
      # Overvej også disse sikkerhedsindstillinger:
      KbdInteractiveAuthentication = false;
      PermitEmptyPasswords = false;
      X11Forwarding = false;    # Deaktiver hvis ikke nødvendigt
    };
  };

  security.sudo.wheelNeedsPassword = false; # 🟢 Convenient, men vær opmærksom på sikkerhedsimplikationer

  # SSH-nøgle konfiguration - sørg for formatet er korrekt
  users.users."Togo-GT" = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # 🛠️ Vigtigt: Brugeren skal være i wheel group for sudo
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGqRnOgrK3+tVuWYuyikrgbxAlA84lizDk4yV7JgFUu0 michael.kaare.nielse@gmail.com"
    ];
  };


  # ----------------------------
  # 🔊 Audio & Printing
  # ----------------------------
  services.printing.enable = true;             # 🖨 Enable CUPS
  services.pulseaudio.enable = false;          # ❌ Disable PulseAudio
  security.rtkit.enable = true;                # 🎵 Realtime audio support

  services.pipewire = {
    enable = true;                             # 🎧 PipeWire audio
    alsa.enable = true;                        # 🔊 ALSA support
    alsa.support32Bit = true;                  # 🖥 32-bit ALSA
    pulse.enable = true;                       # 🔉 Pulse compatibility
  };

  # ----------------------------
  # 👤 Users
  # ----------------------------
  users.users.gt = {
    isNormalUser = true;                       # 🧑‍💻 Normal user
    description = "gt";
    extraGroups = [ "networkmanager" "wheel" ]; # 👥 User groups
    packages = with pkgs; [
      kdePackages.kate   # ✍️ KDE editor
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;


  # ----------------------------
  # 🐚 Shell / Terminal
  # ----------------------------
  programs.zsh = {
    enable = true;                             # 🐚 Aktivér Zsh
    enableCompletion = true;                   # ✅ Autocompletion
    autosuggestions.enable = true;             # 💡 Forslag mens du skriver
    syntaxHighlighting.enable = true;          # 🎨 Syntax highlighting

    ohMyZsh = {                                # ⬅️ nyt navn (camelCase)
      enable = true;                           # ⚡ Aktivér Oh My Zsh
      theme = "robbyrussell";                  # 🎭 Tema
      plugins = [
        "git"                                  # 🌱 Git integration
        "z"                                    # 📂 Hurtig navigation
        "sudo"                                 # 🔑 Sudo shortcut
        "autojump"                             # 🚀 Hop hurtigt i mapper
        "syntax-highlighting"                  # 🎨 Syntax highlighting plugin
        "history-substring-search"             # ⏮ Historik-søgning
      ];
    };
  };


  # 🛠 CLI-værktøjer
  environment.systemPackages = with pkgs; [
    wget        # 🌐 Downloads
    curl        # 🌐 Downloads
    htop        # 📊 Monitor
    neofetch    # 💻 System info
    tree        # 🌲 Mappeoversigt
    nil         # 🟢 Nix LSP server til editor
    bash
    git
  ];

  # ----------------------------
  # 🌐 Netværk & Crypto
  # ----------------------------
  programs.mtr.enable = true;                  # 📡 Network diagnostics

  programs.gnupg.agent = {
    enable = true;                             # 🔑 GPG agent
    enableSSHSupport = true;                   # 🔑 SSH support
  };

  # ----------------------------
  # 🔥 Firewall
  # ----------------------------
  networking.firewall.allowedTCPPorts = [ 22 80 443 ]; # 🔒 TCP ports
  networking.firewall.allowedUDPPorts = [ 53 ];        # 🔒 UDP ports

  # ----------------------------
  # 🚀 Nix / Flakes
  # ----------------------------
  nix = {
    package = pkgs.nixVersions.latest;         # 🧪 Latest Nix
    settings.experimental-features = [ "nix-command" "flakes" ]; # ⚡ Flakes
  };

  # ----------------------------
  # ⚡ System version
  # ----------------------------
  system.stateVersion = "25.05";               # 📌 Required
}
#GT-nixos-btw 

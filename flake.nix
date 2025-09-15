{
  description = "NixOS 25.05 config for nixos-btw with Home Manager ✨";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        # ----------------------------
        # Hardware config
        # ----------------------------
        ({ lib, config, ... }: {
          boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
          boot.kernelModules = [ "iwlwifi" "kvm-intel" ];
          hardware.enableRedistributableFirmware = true;

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/8f424373-0299-411b-82ba-475f6289a59d";
            fsType = "ext4";
          };
          swapDevices = [ ];
          networking.useDHCP = lib.mkDefault true;
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
        })

        # ----------------------------
        # System basics
        # ----------------------------
        {
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

          services.xserver.enable = true;
          services.displayManager.sddm.enable = true;
          services.desktopManager.plasma6.enable = true;
          services.displayManager.defaultSession = "plasma";

          services.xserver.xkb.layout = "dk";
          console.keyMap = "dk-latin1";

          services.openssh.enable = true;
          services.openssh.settings = {
            PermitRootLogin = "no";
            PasswordAuthentication = false;
          };

          security.sudo.wheelNeedsPassword = false;

          services.printing.enable = true;
          services.pulseaudio.enable = false;
          security.rtkit.enable = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };

          programs.ssh.startAgent = true;

          users.users.Togo-GT = {
            isNormalUser = true;
            extraGroups = [ "networkmanager" "wheel" ];
            description = "Togo-GT";
            packages = with pkgs; [ kdePackages.kate firefox ];
          };

          networking.firewall.allowedTCPPorts = [ 22 80 443 ];
          networking.firewall.allowedUDPPorts = [ 53 ];

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          system.stateVersion = "25.05";
        }

        # ----------------------------
        # Home Manager integration
        # ----------------------------
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.users.Togo-GT = { pkgs, lib, ... }: {
            home.username = "Togo-GT";
            home.homeDirectory = "/home/Togo-GT";
            home.stateVersion = "25.05";
            home.enableNixpkgsReleaseCheck = false;

            programs.zsh.enable = true;

            home.sessionVariables = {
              SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/ssh-agent";
            };
          };
        }

        # ----------------------------
        # Auto Wi-Fi module
        # ----------------------------
        (import ./modules/autoWifi.nix)

        # ----------------------------
        # Systemd timers/services
        # ----------------------------
        {
          systemd.timers.cleanOldHomeManagerBackups = {
            description = "Ryd gamle Home Manager backup-filer over 30 dage gamle";
            timerConfig.OnCalendar = "*-*-* 03:00:00";
            timerConfig.Persistent = true;
            wantedBy = [ "timers.target" ];
          };

          systemd.services.cleanOldHomeManagerBackups = {
            description = "Fjern Home Manager backups ældre end 30 dage";
            serviceConfig.Type = "oneshot";
            serviceConfig.ExecStart = "${pkgs.bash}/bin/bash -c 'mkdir -p /home/Togo-GT/backups/home-manager && find /home/Togo-GT/backups/home-manager -type f -name \"*.backup\" -mtime +30 -exec rm -v {} \\;'";
            wantedBy = [ "multi-user.target" ];
          };

          systemd.timers.nix-garbage-collection = {
            description = "Automatic Nix garbage collection";
            timerConfig = {
              OnCalendar = "weekly";
              Persistent = true;
              RandomizedDelaySec = "1h";
            };
            wantedBy = [ "timers.target" ];
          };

          systemd.services.nix-garbage-collection = {
            description = "Run nix-collect-garbage -d";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${pkgs.nix}/bin/nix-collect-garbage -d";
              User = "root";
            };
            wantedBy = [ "multi-user.target" ];
          };
        }

      ];
    };
  };
}

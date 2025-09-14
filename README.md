┌─────────────────────────────┐
│       nixos-rebuild         │
└─────────────────────────────┘

1️⃣ Byg og aktiver systemet (permanent)
   ──────────────────────────
   sudo nixos-rebuild switch

2️⃣ Byg systemet uden aktivering
   ──────────────────────────
   sudo nixos-rebuild build
   → output i /result

3️⃣ Test ændringer midlertidigt
   ──────────────────────────
   sudo nixos-rebuild test

4️⃣ Opdater kanaler + aktiver system
   ──────────────────────────
   sudo nixos-rebuild switch --upgrade

5️⃣ Gå tilbage til forrige generation
   ──────────────────────────
   sudo nixos-rebuild switch --rollback

6️⃣ Brug flake som kilde
   ──────────────────────────
   sudo nixos-rebuild switch --flake /path/to/flake#hostname

7️⃣ Fejl og debugging flags
   ──────────────────────────
   --keep-going    → fortsæt selvom nogle pakker fejler
   --fast          → byg med cache, spring downloads over
   --show-trace    → detaljeret fejlspor

💡 Tips:
- switch = permanent
- test   = midlertidigt
- build  = kun bygning
- rollback = nødstop

GT    sudo nixos-rebuild switch --flake /etc/nixos#nixos-btw --upgrade

GT    nix flake update

gt nix flake lock --update-input home-manager
nix flake update


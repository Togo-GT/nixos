├── flake.nix               # ✅ Flake-entrypunkt
├── configuration.nix       # ✅ Hovedsystemmodul
├── hosts/
│   ├── default.nix         # ✅ Basisværtskonfiguration
│   ├── laptop/
│   │   ├── default.nix     # ✅ Bærbar-specifik konfig
│   │   └── hardware.nix    # ✅ Hardware-specifik konfig
│   └── server/
│       └── default.nix     # ✅ Server-specifik konfig
└── modules/
    ├── home-manager/       # ✅ Brugerkonfigurationer
    ├── services/           # ✅ Tjenestekonfigurationer
    └── packages.nix        # ✅ Pakkedefinitioner

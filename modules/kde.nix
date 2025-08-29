{ config, pkgs, ... }:

let
  # Helper til at tjekke om pakken eksisterer
  safePkg = pkg: let r = builtins.tryEval pkg; in if r.success then r.value else null;
in
{
  # --------------------------------------
  # KDE applications 🖥️
  # --------------------------------------
  environment.systemPackages = builtins.filter (x: x != null) [

    #safePkg pkgs.kdePackages.kate       # 📝 Text editor
    #safePkg pkgs.kdePackages.kdevelop   # 👨‍💻 IDE
    #safePkg pkgs.kdePackages.kdenlive   # 🎞 Video editor
    #safePkg pkgs.kdePackages.dolphin    # 🗂 File manager
    #safePkg pkgs.kdePackages.konsole    # 💻 Terminal emulator
    #safePkg pkgs.kdePackages.kcalc      # 🔢 Calculator
    #safePkg pkgs.kdePackages.kwrite     # 📝 Lightweight text editor
    #safePkg pkgs.kdePackages.krita      # 🎨 Digital painting
    #safePkg pkgs.kdePackages.okular     # 📖 PDF viewer
    #safePkg pkgs.kdePackages.kmag       # 🔍 Magnifier
    #safePkg pkgs.kdePackages.kdialog    # 🛠 Dialog utility
    #safePkg pkgs.kdePackages.ksystemlog # 📜 System log viewer

  ];
}

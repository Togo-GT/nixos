{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;                   # 🔧 Git CLI
    config = {
      user.name = "Togo-GT";
      user.email = "michael.kaare.nielsen@gmail.com";
      init.defaultBranch = "main";
    };
  };
}

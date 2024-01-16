{ lib, config, ... }:

with lib;
let
  cfg = config.modules.desktop.xfce;
in {
  options.modules.desktop.xfce = {
    enable = mkEnableOption "Enable Xfce, a lightweight desktop environment based on GTK+";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = true;
      };
      displayManager.defaultSession = "xfce";
    };
  };
}
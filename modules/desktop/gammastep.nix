{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.gammastep;
in {
  options.modules.desktop.gammastep = {
    enable = mkEnableOption "Enable gammastep, a blue-light filter for Wayland desktop environments";
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = [ "${pkgs.gammastep}/bin/gammastep-indicator" ];
    hm.services.gammastep = {
      enable = true;
      # moscow, russia
      latitude = 55.751244;
      longitude = 37.618423;
      provider = "manual";
    };
  };
}
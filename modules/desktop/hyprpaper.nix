{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.hyprpaper;
in {
  options.modules.desktop.hyprpaper = {
    enable = mkEnableOption "Enable Hyprpaper, a blazing fast wayland wallpaper utility";
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = [ "${lib.getExe pkgs.hyprpaper}" ];
    hm.xdg.configFile."hypr/hyprpaper.conf" = let
      img = ../../assets/wallpaper.png;
    in {
      text = ''
        preload = ${img}
        wallpaper = ,${img}
        splash = false
      '';
    };
  };
}
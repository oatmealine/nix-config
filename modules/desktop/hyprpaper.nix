{ lib, config, inputs, system, ... }:

with lib;
let
  cfg = config.modules.desktop.hyprpaper;
in {
  options.modules.desktop.hyprpaper = {
    enable = mkEnableOption "Enable Hyprpaper, a blazing fast wayland wallpaper utility";
    package = mkOption {
      type = types.package;
      default = inputs.hyprpaper.packages.${system}.hyprpaper;
      example = "pkgs.hyprpaper";
    };
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = [ "${lib.getExe cfg.package}" ];
    hm.xdg.configFile."hypr/hyprpaper.conf" = let
      img = ../../assets/wp2.webp;
    in {
      text = ''
        preload = ${img}
        wallpaper = ,${img}
        splash = false
      '';
    };
  };
}
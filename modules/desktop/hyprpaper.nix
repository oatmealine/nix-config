{ lib, config, inputs, system, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.hyprpaper;
  # these should probably be options but oh well
  wallpapersFolder = "$XDG_PICTURES_DIR/wallpapers/";
  lastWallpaperPath = "$XDG_DATA_HOME/hyprpaper-lastwp";
in {
  options.modules.desktop.hyprpaper = {
    enable = mkEnableOption "Enable Hyprpaper, a blazing fast wayland wallpaper utility";
    package = mkOption {
      type = types.package;
      default = inputs.hyprpaper.packages.${system}.hyprpaper;
      example = "pkgs.hyprpaper";
    };
    startScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "hyprpaper-start" ''
        ${lib.getExe cfg.package}
        wallpaper=$(cat "${lastWallpaperPath}")
        ${config.modules.desktop.hyprland.package}/bin/hyprctl hyprpaper preload "$wallpaper"
        ${config.modules.desktop.hyprland.package}/bin/hyprctl hyprpaper wallpaper ",$wallpaper"
      '';
    };
    swapScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "hyprpaper-swap" ''
        base="${wallpapersFolder}"
        file=$(ls "$base" | rofi -dmenu -sep '\n' -i -p 'wallpaper select')
        wallpaper="$base/$file"

        [ ! -f "$wallpaper" ] && exit 0

        hyprctl hyprpaper unload all
        hyprctl hyprpaper preload "$wallpaper"
        hyprctl hyprpaper wallpaper ",$wallpaper"

        echo "$wallpaper" > "${lastWallpaperPath}"
      '';
    };
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = [ "${cfg.startScript}" ];
    hm.xdg.configFile."hypr/hyprpaper.conf".text = "splash = false";
  };
}
{ lib, config, inputs, system, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.swww;
  # these should probably be options but oh well
  wallpapersFolder = "$XDG_PICTURES_DIR/wallpapers/";
  lastWallpaperPath = "$XDG_DATA_HOME/swww-lastwp";
in {
  options.modules.desktop.swww = {
    enable = mkEnableOption "Enable swww, a Solution to your Wayland Wallpaper Woes";
    package = mkOption {
      type = types.package;
      default = pkgs.swww;
      example = "pkgs.swww";
    };
    startScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "swww-start" ''
        ${cfg.package}/bin/swww-daemon &
        wallpaper=$(cat "${lastWallpaperPath}")
        ${lib.getExe cfg.package} img "$wallpaper" --transition-type none
      '';
    };
    swapScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "swww-swap" ''
        base="${wallpapersFolder}"
        file=$(ls "$base" | rofi -dmenu -sep '\n' -i -p 'wallpaper select')
        wallpaper="$base/$file"

        [ ! -f "$wallpaper" ] && exit 0

        ${lib.getExe cfg.package} img "$wallpaper" --transition-type grow --transition-fps 60 --transition-pos 0.915,0.977 --transition-duration 1.5

        echo "$wallpaper" > "${lastWallpaperPath}"
      '';
    };
  };

  config = mkIf cfg.enable {
    modules.desktop.execOnStart = [ "${cfg.startScript}" ];
  };
}
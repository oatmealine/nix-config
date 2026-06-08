{ lib, config, inputs, system, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.awww;
  # these should probably be options but oh well
  wallpapersFolder = "$XDG_PICTURES_DIR/wallpapers/";
  blurredWallpapersFolder = "$XDG_PICTURES_DIR/wallpapers/.blurcache";
  lastWallpaperPath = "$XDG_DATA_HOME/awww-lastwp";
in {
  options.modules.desktop.awww = {
    enable = mkEnableOption "Enable awww, a Asolution to your Wayland Wallpaper Woes";
    package = mkOption {
      type = types.package;
      default = pkgs.awww;
      example = "pkgs.awww";
    };
    blurredDuplicate = mkEnableOption "Run swaybg aswell with a blurred version of the wallpaper, for niri overviews";
    swaybgPackage = mkOption {
      type = types.package;
      default = pkgs.swaybg;
      example = "pkgs.swaybg";
    };
    vipsPackage = mkOption {
      type = types.package;
      default = pkgs.vips;
      example = "pkgs.vips";
    };
    startScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "awww-start" (''
        ${cfg.package}/bin/awww-daemon &
        wallpaper=$(cat "${lastWallpaperPath}")
        ${lib.getExe cfg.package} img "$wallpaper" --transition-type none
      '' + (if cfg.blurredDuplicate then ''
        blurWallpaper="${blurredWallpapersFolder}"/$(basename "$wallpaper")
        [ ! -f "$blurWallpaper" ] && exit 0
        ${lib.getExe cfg.swaybgPackage} -i "$blurWallpaper" &
      '' else ""));
    };
    swapScript = mkOption {
      type = types.package;
      default = pkgs.writeScript "awww-swap" (''
        base="${wallpapersFolder}"
        file=$(ls "$base" | rofi -dmenu -sep '\n' -i -p 'wallpaper select')
        wallpaper="$base/$file"

        [ ! -f "$wallpaper" ] && exit 0

        ${lib.getExe cfg.package} img "$wallpaper" --transition-type grow --transition-fps 60 --transition-pos 0.915,0.977 --transition-duration 1.5

        echo "$wallpaper" > "${lastWallpaperPath}"
      '' + (if cfg.blurredDuplicate then ''
        blurWallpaper="${blurredWallpapersFolder}"/$(basename "$wallpaper")
        [ ! -f "$blurWallpaper" ] \
          && ${lib.getExe cfg.vipsPackage} gaussblur "$wallpaper" "$blurWallpaper".v 35 \
          && ${lib.getExe cfg.vipsPackage} gamma "$blurWallpaper".v "$blurWallpaper" --exponent 0.65 \
          && rm "$blurWallpaper".v

        killall .swaybg-wrapped
        ${lib.getExe cfg.swaybgPackage} -i "$blurWallpaper" &
      '' else ""));
    };
  };

  config = mkIf cfg.enable {
    hm.home.packages = [ cfg.package ];
    modules.desktop.execOnStart = [ "${cfg.startScript}" ];
  };
}

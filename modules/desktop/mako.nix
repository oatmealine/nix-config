{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.mako;
in {
  options.modules.desktop.mako = {
    enable = mkEnableOption "Enable mako, a lightweight notification daemon for Wayland";
    osd = mkEnableOption "Use mako as an OSD for volume/brightness";
    package = mkOption {
      type = types.package;
      default = pkgs.mako;
    };
    backlightScript = mkOption {
      type = types.package;
      default = pkgs.symlinkJoin (let
        script = (pkgs.writeScriptBin "mako-osd-backlight" (builtins.readFile ./mako-osd-backlight.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in {
        name = "mako-osd-backlight";
        paths = with pkgs; [ script brightnessctl libnotify gnused gawk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/mako-osd-backlight --prefix PATH : $out/bin";
      });
    };
    volumeScript = mkOption {
      type = types.package;
      default = pkgs.symlinkJoin (let
        script = (pkgs.writeScriptBin "mako-osd-volume" (builtins.readFile ./mako-osd-volume.sh)).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });
      in {
        name = "mako-osd-volume";
        paths = with pkgs; [ script wireplumber libnotify gnused ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/mako-osd-volume --prefix PATH : $out/bin";
      });
    };
  };

  config = mkIf cfg.enable {
    hm.services.mako = {
      enable = true;
      anchor = "top-right";
      borderRadius = 6;
      borderSize = 2;
      defaultTimeout = 4000;
      font = with config.modules.desktop.fonts.fonts.sans; "${family} ${toString (size - 1)}";
      width = 300;
      height = 200;
      margin = "8";
      padding = "12";
      maxIconSize = 48;
      layer = "overlay";
    };
    modules.desktop.execOnStart = [ "${lib.getExe cfg.package}" ];
  };
}
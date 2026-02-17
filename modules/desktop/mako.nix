{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.mako;

  mkScript = name: path: deps:
    pkgs.symlinkJoin (let
      script = (pkgs.writeScriptBin name (builtins.readFile path)).overrideAttrs(old: {
        buildCommand = "${old.buildCommand}\n patchShebangs $out";
      });
    in {
      inherit name;
      paths = [ script ] ++ deps;
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
      meta.mainProgram = name;
    });
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
      default = mkScript "mako-osd-backlight" ./mako-osd-backlight.sh (with pkgs; [ brightnessctl libnotify gnused gawk ]);
    };
    volumeScript = mkOption {
      type = types.package;
      default = mkScript "mako-osd-volume" ./mako-osd-volume.sh (with pkgs; [ wireplumber libnotify gnused ]);
    };
    niriKeyboardScript = mkOption {
      type = types.package;
      default = mkScript "mako-osd-niri-keyboard" ./mako-osd-niri-keyboard.sh (with pkgs; [ jq libnotify ]);
    };
  };

  config = mkIf cfg.enable {
    hm.services.mako = {
      enable = true;
      settings = {
        anchor = "top-right";
        border-radius = 6;
        border-size = 2;
        default-timeout = 4000;
        font = with config.modules.desktop.fonts.fonts.sans; "${family} ${toString (size - 1)}";
        width = 300;
        height = 200;
        margin = "8";
        padding = "12";
        max-icon-size = 48;
        layer = "overlay";
      };
    };
    modules.desktop.execOnStart = [ "${lib.getExe cfg.package}" ];
    # this is niri-specific, so this is Normal, actually
    hm.programs.niri.settings.spawn-at-startup = [{ command = [ "${lib.getExe cfg.niriKeyboardScript}" ]; } ];
  };
}
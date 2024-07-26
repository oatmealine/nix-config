{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.wob;
in {
  options.modules.desktop.wob = {
    enable = mkEnableOption "Enable wob, a Wayland overlay bar";
    sockPath = mkOption {
      description = "Wob sock location";
      type = types.str;
      default = "$XDG_RUNTIME_DIR/wob.sock";
    };
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = let
      path = cfg.sockPath;
      script = pkgs.writeScript "launch-wob" ''
        rm -f ${path} && mkfifo ${path} && tail -f ${path} | ${lib.getExe pkgs.wob}
      '';
    in [ script ];
    hm.services.wob = {
      enable = true;
      settings = {
        "" = {
          timeout = 1000;
          
          border_offset = 2;
          border_size = 2;
          bar_padding = 2;

          anchor = "top";
          width = 300;
          height = 30;

          margin = 12;

          overflow_mode = "nowrap";
          output_mode = "focused";
        };
      };
    };
  };
}
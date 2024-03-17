{ lib, config, pkgs, system, inputs, ... }:

with lib;
let
  cfg = config.modules.desktop.hypridle;
in {
  options.modules.desktop.hypridle = {
    enable = mkEnableOption "Enable hypridle, Hyprland's idle daemon";
    package = mkOption {
      type = types.package;
      default = inputs.hypridle.packages.${system}.hypridle;
      example = "pkgs.hypridle";
    };
  };

  config = mkIf cfg.enable {
    hm.services.hypridle = {
      enable = true;
      package = cfg.package;

      lockCmd = "${lib.getExe config.modules.desktop.hyprlock.package}";
      unlockCmd = "pkill -USR1 hyprlock";

      listeners = let
        hyprctl = "${config.modules.desktop.hyprland.package}/bin/hyprctl";
      in [
        {
          timeout = 60 * 1; # 1 min
          onTimeout = "${lib.getExe pkgs.brightnessctl} -s set 20";
          onResume = "${lib.getExe pkgs.brightnessctl} -r" ;
        }
        {
          timeout = 90; # 1.5 min
          onTimeout = "${hyprctl} dispatch dpms off"; # turn off screen
          onResume = "${hyprctl} dispatch dpms on"; # turn it back on
        }
        {
          timeout = 60 * 2; # 2 min
          onTimeout = "loginctl lock-session"; # lock the system
        }
        {
          timeout = 60 * 5; # 5 min
          onTimeout = "systemctl suspend"; # suspend
        }
      ];
    };
  };
}
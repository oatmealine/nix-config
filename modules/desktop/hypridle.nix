{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.hypridle;
in {
  options.modules.desktop.hypridle = {
    enable = mkEnableOption "Enable hypridle, Hyprland's idle daemon";
  };

  config = mkIf cfg.enable {
    hm.services.hypridle = {
      enable = true;

      lockCmd = "${lib.getExe config.hm.programs.hyprlock.package}";
      unlockCmd = "pkill -USR1 hyprlock";

      listeners = [
        {
          timeout = 60 * 1; # 1 min
          onTimeout = "${lib.getExe pkgs.brightnessctl} -s set 20";
          onResume = "${lib.getExe pkgs.brightnessctl} -r" ;
        }
        {
          timeout = 90; # 1.5 min
          onTimeout = "hyprctl dispatch dpms off"; # turn off screen
          onResume = "hyprctl dispatch dpms on"; # turn it back on
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
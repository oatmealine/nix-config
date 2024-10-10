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
    hm.home.packages = [ cfg.package inputs.vigiland.packages.${system}.vigiland ];
    hm.services.hypridle = {
      enable = true;
      package = cfg.package;
      settings = {
        general = {
          lock_cmd = "${lib.getExe config.modules.desktop.hyprlock.package}";
          #after_sleep_cmd = "pkill -USR1 hyprlock";
        };

        listener = [
          {
            timeout = 60 * 1; # 1 min
            on-timeout = "${lib.getExe pkgs.brightnessctl} -s set 20";
            on-resume = "${lib.getExe pkgs.brightnessctl} -r" ;
          }
          {
            timeout = 60 * 2; # 2 min
            on-timeout = "loginctl lock-session"; # lock the system
          }
          {
            timeout = 60 * 5; # 5 min
            on-timeout = "systemctl suspend"; # suspend
          }
        ] ++ optional config.modules.desktop.hyprland.enable (let 
          hyprctl = "${config.modules.desktop.hyprland.package}/bin/hyprctl";
        in {
          timeout = 90; # 1.5 min
          on-timeout = "${hyprctl} dispatch dpms off"; # turn off screen
          on-resume = "${hyprctl} dispatch dpms on"; # turn it back on
        }) ++ optional config.modules.desktop.niri.enable {
          timeout = 90; # 1.5 min
          on-timeout = "niri msg action power-off-monitors";
        };
      };
    };
  };
}
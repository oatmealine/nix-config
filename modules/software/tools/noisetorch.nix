{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.tools.noisetorch;
in {
  options.modules.software.tools.noisetorch = {
    enable = mkEnableOption "Enable noisetorch, a microphone noise supression tool";
    package = mkOption {
      type = types.package;
      default = pkgs.noisetorch;
    };
    autostart = {
      enable = mkEnableOption "Enable autostart on bootup";
      device = {
        unit = mkOption {
          description = "The micrphone unit name to wait for (check `systemctl list-units --type=device`)";
          type = types.str;
        };
        name = mkOption {
          description = "The microphone name to use as an input (check `noisetorch -l`)";
          type = types.str;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.noisetorch.enable = true;

    systemd.user.services.noisetorch = mkIf cfg.autostart.enable {
      description = "Noisetorch noise cancelling";
      wantedBy = [ "graphical-session.target" ];
      after = [ cfg.autostart.device.unit ];
      requires = [ cfg.autostart.device.unit ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe cfg.package} -i -s ${cfg.autostart.device.name} -t 95";
        ExecStop = "${lib.getExe cfg.package} -u";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
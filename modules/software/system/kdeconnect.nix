{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.kdeconnect;
in {
  options.modules.software.system.kdeconnect = {
    enable = mkEnableOption "Enable kdeconnect, a multi-platform app that allows your devices to communicate";
    package = mkOption {
      type = types.package;
      default = pkgs.kdePackages.kdeconnect-kde;
    };
  };

  config = mkIf cfg.enable {
    programs.kdeconnect.enable = true;

    modules.desktop.execOnStart = [
      "${cfg.package}/bin/kdeconnectd"
      "${cfg.package}/bin/kdeconnect-indicator"
    ];
  };
}
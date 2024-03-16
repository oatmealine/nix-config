{ lib, config, ... }:

with lib;
let
  cfg = config.modules.desktop.dunst;
in {
  options.modules.desktop.dunst = {
    enable = mkEnableOption "Enable dunst, a lightweight replacement for the notification daemons provided by most desktop environments";
  };

  config = mkIf cfg.enable {
    hm.services.dunst = {
      enable = true;
      configFile = ../../config/dunst.conf;
    };
  };
}
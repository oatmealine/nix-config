{ config, lib, ... }:

with lib;
let
  cfg = config.modules.software.system.syncthing;
in {
  options.modules.software.system.syncthing = {
    enable = mkEnableOption "Enable Syncthing, a file synchronization server";
  };

  config = mkIf cfg.enable {
    # declare sync folders & devices here
    # edit: turns out you can't with hm. huh
    hm.services.syncthing.enable = true;
    hm.services.syncthing.tray.enable = true;
  };
}
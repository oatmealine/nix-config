{ config, lib, ... }:

with lib;
let
  cfg = config.modules.software.tools.noisetorch;
in {
  options.modules.software.tools.noisetorch = {
    enable = mkEnableOption "Enable noisetorch, a microphone noise supression tool";
  };

  config = mkIf cfg.enable {
    programs.noisetorch.enable = true;
  };
}
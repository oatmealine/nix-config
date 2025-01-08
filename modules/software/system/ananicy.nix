{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.ananicy;
in {
  options.modules.software.system.ananicy = {
    enable = mkEnableOption "Enable Ananicy, an auto nice daemon with community rules support";
  };

  config = mkIf cfg.enable {
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-rules-cachyos;
    };
  };
}
{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.flatpak;
in {
  options.modules.software.system.flatpak = {
    enable = mkEnableOption "Enable flatpak, an application sandboxing and distribution framework";
  };

  config = mkIf cfg.enable {
    services.flatpak.enable = true;
    hm.home.packages = [ pkgs.flatpak ];
    fonts.fontDir.enable = true;
  };
}
{ lib, config, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.desktop.cliphist;
in {
  options.modules.desktop.cliphist = {
    enable = mkEnableOption "Enable cliphist, a clipboard \"manager\" for Wayland";
    package = mkOption {
      type = types.package;
      default = pkgs.cliphist;
    };
    summonCmd = mkOption {
      #default = "${lib.getExe config.modules.desktop.rofi.package} -modi clipboard:${cliphist-rofi-img} -show clipboard -show-icons";
      default = "${lib.getExe cfg.package} list | ${lib.getExe config.modules.desktop.rofi.package} -dmenu -display-columns 2 | ${lib.getExe cfg.package} decode | ${pkgs.wl-clipboard}/bin/wl-copy";
    };
  };

  config = mkIf cfg.enable {
    hm.services.cliphist = {
      enable = true;
      allowImages = true;
      package = cfg.package;
    };
    modules.desktop.rofi.enable = true;
    hm.home.packages = [
      cfg.package pkgs.wl-clipboard
    ];
  };
}
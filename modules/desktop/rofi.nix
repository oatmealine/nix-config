{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.rofi;
in {
  options.modules.desktop.rofi = {
    enable = mkEnableOption "Enable rofi, a window switcher, run dialog and dmenu replacement";
    package = mkOption {
      type = types.package;
      default = pkgs.rofi;
    };
  };

  config = mkIf cfg.enable {
    hm.programs.rofi = {
      enable = true;
      package = cfg.package;
      font = "Recursive 12";
      #font = with config.modules.desktop.fonts.fonts.monospace; "${family} ${toString (size - 1)}";
      extraConfig = {
        show-icons = true;
      };
    };
  };
}
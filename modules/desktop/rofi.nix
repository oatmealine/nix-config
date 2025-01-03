{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.rofi;
in {
  options.modules.desktop.rofi = {
    enable = mkEnableOption "Enable rofi, a window switcher, run dialog and dmenu replacement";
  };

  config = mkIf cfg.enable {
    hm.programs.rofi = {
      enable = true;
      package = pkgs.rofi-wayland-unwrapped;
      font = with config.modules.desktop.fonts.fonts.monospace; "${family} ${toString (size - 1)}";
      extraConfig = {
        show-icons = true;
      };
    };
  };
}
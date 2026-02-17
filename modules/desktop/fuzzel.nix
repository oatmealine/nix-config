{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.fuzzel;
in {
  options.modules.desktop.fuzzel = {
    enable = mkEnableOption "Enable fuzzel, an application launcher similar to rofi's drun mode";
    package = mkOption {
      type = types.package;
      default = pkgs.fuzzel;
    };
  };

  config = mkIf cfg.enable {
    hm.programs.fuzzel = {
      enable = true;
      package = cfg.package;
      settings = {
        main = {
          terminal = "wezterm start";
          #font = with config.modules.desktop.fonts.fonts; "${monospace.family}:size=${toString ((monospace.size - 3) * 2 + 1)}"; # ?
          # todo: maybe good to have a monospace-secondary/monospace-legible for cases like this?
          font = "Recursive:size=10";
          prompt = "";
          #dpi-aware = "no";
          lines = 20;
          width = 28;
          #letter-spacing = 0.5;
          horizontal-pad = 32;
          vertical-pad = 8;
        };
      };
    };
  };
}
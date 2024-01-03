# alacritty - a cross-platform, GPU-accelerated terminal emulator

{ lib, config, inputs, ... }:

with lib;
let
  cfg = config.alacritty;
in {
  options.alacritty = {
    enable = mkEnableOption "Enable Alacritty config";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      # custom settings
      settings = {
        env.TERM = "xterm-256color";
        window.resize_increments = true;
        colors.draw_bold_text_with_bright_colors = true;
        font = {
          normal = { family = config.opinions.fonts.monospaceBitmap.family; };
          size = config.opinions.fonts.monospaceBitmap.size;
        };
      };
    };
  };
}
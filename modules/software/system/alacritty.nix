{ lib, config, ... }:

with lib;
let
  cfg = config.modules.software.system.alacritty;
in {
  options.modules.software.system.alacritty = {
    enable = mkEnableOption "Enable Alacritty, an OpenGL terminal emulator";
  };

  config = mkIf cfg.enable {
    hm.programs.rofi.terminal = "alacritty";
    hm.programs.alacritty = {
      enable = true;
      # custom settings
      settings = {
        env.TERM = "xterm-256color";
        window.resize_increments = true;
        colors.draw_bold_text_with_bright_colors = true;
        font = with config.modules.desktop.fonts.fonts.monospaceBitmap; {
          normal = { inherit family; };
          inherit size;
        };
      };
    };
  };
}
{ lib, config, ... }:

with lib;
let
  cfg = config.modules.software.system.wezterm;
in {
  options.modules.software.system.wezterm = {
    enable = mkEnableOption "Enable wezterm";
  };

  config = mkIf cfg.enable {
    hm.programs.wezterm = {
      enable = true;
      # custom settings
      #settings = {
      #  env.TERM = "xterm-256color";
      #  window.resize_increments = true;
      #  colors.draw_bold_text_with_bright_colors = true;
      #  font = with config.modules.desktop.fonts.fonts.monospaceBitmap; {
      #    normal = { inherit family; };
      #    inherit size;
      #  };
      #};
      extraConfig = let 
        fonts = config.modules.desktop.fonts.fonts;
      in ''
        local wezterm = require 'wezterm'
        local config = {}

        config.font = wezterm.font '${fonts.monospaceBitmap.family}'
        config.font_size = ${toString fonts.monospaceBitmap.size}
        config.freetype_load_flags = 'MONOCHROME'
        --config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
        config.enable_wayland = false
        config.color_scheme = 'Catppuccin Mocha'
        config.use_fancy_tab_bar = false
        config.use_resize_increments = true
        config.initial_cols = 120
        config.initial_rows = 40

        config.window_frame = {
          font = wezterm.font '${fonts.sans.family}',
          font_size = ${toString fonts.sans.size},
        }

        return config
      '';
    };
  };
}
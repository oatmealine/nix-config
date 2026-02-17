{ lib, config, ... }:

with lib;
let
  cfg = config.modules.software.system.wezterm;
in {
  options.modules.software.system.wezterm = {
    enable = mkEnableOption "Enable wezterm";
  };

  config = mkIf cfg.enable {
    hm.programs.rofi.terminal = "wezterm";
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
        local act = wezterm.action
        local config = {}

        -- https://www.reddit.com/r/wezterm/comments/1eze6zt/comment/ljncdct/
        config.front_end = 'WebGpu'
        config.font = wezterm.font('${fonts.monospaceBitmap.family}', { style = 'Normal', weight = 'Medium' })
        config.font_size = ${toString (fonts.monospaceBitmap.size - 1)}
        config.cell_width = 0.8
        config.freetype_load_flags = 'MONOCHROME'
        --config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
        config.enable_wayland = ${if (!config.modules.desktop.hyprland.enable) then "true" else "false"}
        config.use_fancy_tab_bar = false
        config.use_resize_increments = true
        config.initial_cols = 120
        config.initial_rows = 40
        config.window_background_opacity = 0.8
        ${config.modules.desktop.themes.wezterm or ""}

        config.window_frame = {
          font = wezterm.font '${fonts.sans.family}',
          font_size = ${toString fonts.sans.size},
        }

        -- https://wezfurlong.org/wezterm/config/mouse.html
        config.mouse_bindings = {
          -- Change the default click behavior so that it only selects
          -- text and doesn't open hyperlinks
          {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'NONE',
            action = act.CompleteSelection 'ClipboardAndPrimarySelection',
          },
          -- Bind 'Up' event of CTRL-Click to open hyperlinks
          {
            event = { Up = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.OpenLinkAtMouseCursor,
          },
          -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
          {
            event = { Down = { streak = 1, button = 'Left' } },
            mods = 'CTRL',
            action = act.Nop,
          },
        }

        return config
      '';
    };
  };
}

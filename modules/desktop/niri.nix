{ lib, config, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.desktop.niri;
in {
  options.modules.desktop.niri = {
    enable = mkEnableOption "Enable niri, a scrollable-tiling Wayland compositor.";
  };

  imports = [ inputs.niri.nixosModules.niri ];

  config = mkIf cfg.enable {
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri = {
      enable = true;
    };
    hm.programs.niri = {
      settings = {
        spawn-at-startup = [
          { command = [ "${lib.getExe pkgs.networkmanagerapplet}" ]; }
          { command = [ "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent" ]; }   # authentication prompts
          { command = [ "${lib.getExe pkgs.wl-clip-persist} --clipboard primary" ]; } # to fix wl clipboards disappearing
        ] ++ (map (cmd: { command = [ "sh" "-c" cmd ]; }) config.modules.desktop.execOnStart);

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
        input = {
          workspace-auto-back-and-forth = true;

          keyboard.xkb = {
            layout = "us,ru";
            variant = "workman,";
            options = "grp:win_space_toggle";
          };

          touchpad = {
            tap = true;
            natural-scroll = true;
            #dwt = true;
          };
        };

        prefer-no-csd = true;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout
        layout = {
          gaps = 6;

          # When to center a column when changing focus, options are:
          # - "never", default behavior, focusing an off-screen column will keep at the left
          #   or right edge of the screen.
          # - "always", the focused column will always be centered.
          # - "on-overflow", focusing a column will center it if it doesn't fit
          #   together with the previously focused column.
          center-focused-column = "on-overflow";

          # You can change the default width of the new windows.
          #default-column-width { proportion 0.5; }
          # If you leave the brackets empty, the windows themselves will decide their initial width.
          # default-column-width {}

          # By default focus ring and border are rendered as a solid background rectangle
          # behind windows. That is, they will show up through semitransparent windows.
          # This is because windows using client-side decorations can have an arbitrary shape.
          #
          # If you don't like that, you should uncomment `prefer-no-csd` below.
          # Niri will draw focus ring and border *around* windows that agree to omit their
          # client-side decorations.
          #
          # Alternatively, you can override it with a window rule called
          # `draw-border-with-background`.

          focus-ring = {
            enable = false;
            width = 1;
            active.color = config.modules.desktop.themes.niri.accent;
            inactive.color = config.modules.desktop.themes.niri.inactive;
          };

          border = {
            enable = true;
            width = 1;
            active.color = config.modules.desktop.themes.niri.accent;
            inactive.color = config.modules.desktop.themes.niri.inactive;
          };
        };

        # Add lines like this to spawn processes at startup.
        # Note that running niri as a session supports xdg-desktop-autostart,
        # which may be more convenient to use.
        # See the binds section below for more spawn examples.
        # spawn-at-startup "alacritty" "-e" "fish"

        screenshot-path = null;

        # Animation settings.
        # The wiki explains how to configure individual animations:
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Animations
        animations = {
          # Uncomment to turn off all animations.
          # off

          # Slow down all animations by this factor. Values below 1 speed them up instead.
          # slowdown 3.0
        };

        # Window rules let you adjust behavior for individual windows.
        # Find more information on the wiki:
        # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules

        # Work around WezTerm's initial configure bug
        # by setting an empty default-column-width.
        window-rules = [
          {
            # This regular expression is intentionally made as specific as possible,
            # since this is the default config, and we want no false positives.
            # You can get away with just app-id="wezterm" if you want.
            matches = [{ app-id = "^org\.wezfurlong\.wezterm$"; }];
            default-column-width = {};
          }
        ];

        binds = with config.hm.lib.niri.actions; {
          # Keys consist of modifiers separated by + signs, followed by an XKB key name
          # in the end. To find an XKB name for a particular key, you may use a program
          # like wev.
          #
          # "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
          # when running as a winit window.
          #
          # Most actions that you can bind here can also be invoked programmatically with
          # `niri msg action do-something`.

          # Mod-Shift-/, which is usually the same as Mod-?,
          # shows a list of important hotkeys.
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          "Mod+D".action = spawn "fuzzel";
          "Super+Alt+L".action = spawn "hyprlock";

          # You can also use a shell. Do this if you need pipes, multiple commands, etc.
          # Note: the entire command goes as a single argument in the end.
          # "Mod+T".action = spawn "bash" "-c" "notify-send hello && exec alacritty";

          # Example volume keys mappings for PipeWire & WirePlumber.
          # The allow-when-locked=true property makes them work even when the session is locked.
          "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".action        = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
          "XF86AudioMute".allow-when-locked = true;
          "XF86AudioMicMute".action     = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
          "XF86AudioMicMute".allow-when-locked = true;

          "Mod+Q".action = close-window;

          "Mod+Left".action  = focus-column-left;
          "Mod+Down".action  = focus-window-down;
          "Mod+Up".action    = focus-window-up;
          "Mod+Right".action = focus-column-right;
          #"Mod+H".action     = focus-column-left;
          #"Mod+J".action     = focus-window-down;
          #"Mod+K".action     = focus-window-up;
          #"Mod+L".action     = focus-column-right;

          "Mod+Shift+Left".action  = move-column-left;
          "Mod+Shift+Down".action  = move-window-down;
          "Mod+Shift+Up".action    = move-window-up;
          "Mod+Shift+Right".action = move-column-right;
          #"Mod+Shift+H".action     = move-column-left;
          #"Mod+Shift+J".action     = move-window-down;
          #"Mod+Shift+K".action     = move-window-up;
          #"Mod+Shift+L".action     = move-column-right;

          # Alternative commands that move across workspaces when reaching
          # the first or last window in a column.
          # "Mod+J".action     = focus-window-or-workspace-down;
          # "Mod+K".action     = focus-window-or-workspace-up;
          # "Mod+Ctrl+J".action     = move-window-down-or-to-workspace-down;
          # "Mod+Ctrl+K".action     = move-window-up-or-to-workspace-up;

          "Mod+Home".action = focus-column-first;
          "Mod+End".action  = focus-column-last;
          "Mod+Ctrl+Home".action = move-column-to-first;
          "Mod+Ctrl+End".action  = move-column-to-last;

          #"Mod+Shift+Left".action  = focus-monitor-left;
          #"Mod+Shift+Down".action  = focus-monitor-down;
          #"Mod+Shift+Up".action    = focus-monitor-up;
          #"Mod+Shift+Right".action = focus-monitor-right;
          #"Mod+Shift+H".action     = focus-monitor-left;
          #"Mod+Shift+J".action     = focus-monitor-down;
          #"Mod+Shift+K".action     = focus-monitor-up;
          #"Mod+Shift+L".action     = focus-monitor-right;

          #"Mod+Shift+Ctrl+Left".action  = move-column-to-monitor-left;
          #"Mod+Shift+Ctrl+Down".action  = move-column-to-monitor-down;
          #"Mod+Shift+Ctrl+Up".action    = move-column-to-monitor-up;
          #"Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
          #"Mod+Shift+Ctrl+H".action     = move-column-to-monitor-left;
          #"Mod+Shift+Ctrl+J".action     = move-column-to-monitor-down;
          #"Mod+Shift+Ctrl+K".action     = move-column-to-monitor-up;
          #"Mod+Shift+Ctrl+L".action     = move-column-to-monitor-right;

          # Alternatively, there are commands to move just a single window:
          # "Mod+Shift+Ctrl+Left".action  = move-window-to-monitor-left;
          # ...

          # And you can also move a whole workspace to another monitor:
          # "Mod+Shift+Ctrl+Left".action  = move-workspace-to-monitor-left;
          # ...

          "Mod+Page_Down".action      = focus-workspace-down;
          "Mod+Page_Up".action        = focus-workspace-up;
          #"Mod+U".action              = focus-workspace-down;
          #"Mod+I".action              = focus-workspace-up;
          "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
          "Mod+Shift+Page_Up".action   = move-column-to-workspace-up;
          #"Mod+Ctrl+U".action         = move-column-to-workspace-down;
          #"Mod+Ctrl+I".action         = move-column-to-workspace-up;

          # Alternatively, there are commands to move just a single window:
          # "Mod+Ctrl+Page_Down".action = move-window-to-workspace-down;
          # ...

          "Mod+Ctrl+Page_Down".action = move-workspace-down;
          "Mod+Ctrl+Page_Up".action   = move-workspace-up;
          #"Mod+Shift+U".action         = move-workspace-down;
          #"Mod+Shift+I".action         = move-workspace-up;

          # You can refer to workspaces by index. However, keep in mind that
          # niri is a dynamic workspace system, so these commands are kind of
          # "best effort". Trying to refer to a workspace index bigger than
          # the current workspace count will instead refer to the bottommost
          # (empty) workspace.
          #
          # For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
          # will all refer to the 3rd workspace.
          "Mod+1".action = focus-workspace 1;
          "Mod+2".action = focus-workspace 2;
          "Mod+3".action = focus-workspace 3;
          "Mod+4".action = focus-workspace 4;
          "Mod+5".action = focus-workspace 5;
          "Mod+6".action = focus-workspace 6;
          "Mod+7".action = focus-workspace 7;
          "Mod+8".action = focus-workspace 8;
          "Mod+9".action = focus-workspace 9;
          "Mod+Shift+1".action = move-column-to-workspace 1;
          "Mod+Shift+2".action = move-column-to-workspace 2;
          "Mod+Shift+3".action = move-column-to-workspace 3;
          "Mod+Shift+4".action = move-column-to-workspace 4;
          "Mod+Shift+5".action = move-column-to-workspace 5;
          "Mod+Shift+6".action = move-column-to-workspace 6;
          "Mod+Shift+7".action = move-column-to-workspace 7;
          "Mod+Shift+8".action = move-column-to-workspace 8;
          "Mod+Shift+9".action = move-column-to-workspace 9;

          # Alternatively, there are commands to move just a single window:
          # "Mod+Ctrl+1".action = move-window-to-workspace 1;

          # Switches focus between the current and the previous workspace.
          # "Mod+Tab".action = focus-workspace-previous;

          "Mod+Comma".action  = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;

          # There are also commands that consume or expel a single window to the side.
          "Mod+BracketLeft".action  = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+F".action = maximize-column;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+C".action = center-column;

          # Finer width adjustments.
          # This command can also:
          # * set width in pixels: "1000"
          # * adjust width in pixels: "-5" or "+5"
          # * set width as a percentage of screen width: "25%"
          # * adjust width as a percentage of screen width: "-10%" or "+10%"
          # Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
          # set-column-width "100" will make the column occupy 200 physical screen pixels.
          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";

          # Finer height adjustments when in column with other windows.
          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Equal".action = set-window-height "+10%";

          # Actions to switch layouts.
          # Note: if you uncomment these, make sure you do NOT have
          # a matching layout switch hotkey configured in xkb options above.
          # Having both at once on the same hotkey will break the switching,
          # since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
          # "Mod+Space".action       = switch-layout "next";
          # "Mod+Shift+Space".action = switch-layout "prev";

          "Print".action = screenshot;
          "Ctrl+Print".action = screenshot-screen;
          "Alt+Print".action = screenshot-window;

          # The quit action will show a confirmation dialog to avoid accidental exits.
          "Mod+Shift+E".action = quit;

          # Powers off the monitors. To turn them back on, do any input like
          # moving the mouse or pressing any other key.
          "Mod+Shift+P".action = power-off-monitors;
        };
      };
    };
  };
}
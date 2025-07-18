{ lib, config, pkgs, inputs, system, ... }:

with lib;
let
  cfg = config.modules.desktop.niri;
in {
  options.modules.desktop.niri = {
    enable = mkEnableOption "Enable niri, a scrollable-tiling Wayland compositor.";
    package = mkOption {
      type = types.package;
      default = pkgs.niri-unstable;
      example = "pkgs.niri";
    };
  };

  imports = [ inputs.niri.nixosModules.niri ];

  config = mkIf cfg.enable {
    hm.home.packages = [ pkgs.xwayland-satellite-unstable ];
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri = {
      enable = true;
      package = cfg.package;
    };
    systemd.user.services.niri-flake-polkit.enable = false;

    hm.programs.niri = {
      settings = let
        allCorners = r: { bottom-left = r; bottom-right = r; top-left = r; top-right = r; };
      in {
        spawn-at-startup = [
          { command = [ "${lib.getExe pkgs.xwayland-satellite-unstable}" ]; }
          { command = [ "${lib.getExe pkgs.networkmanagerapplet}" ]; }
          { command = [ "${pkgs.deepin.dde-polkit-agent}/lib/polkit-1-dde/dde-polkit-agent" ]; }   # authentication prompts
          { command = [ "${lib.getExe pkgs.wl-clip-persist}" "-c" "regular" ]; } # to fix wl clipboards disappearing
        ]
          ++ (map (cmd: { command = [ "sh" "-c" cmd ]; }) config.modules.desktop.execOnStart)
          ++ (optional (config.modules.desktop.hypridle.enable) ({
            command = [ "${lib.getExe config.modules.desktop.hypridle.package}" ];
          }));

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Input
        input = {
          #workspace-auto-back-and-forth = true;

          keyboard.xkb = {
            layout = "us,us,ru";
            variant = ",workman,";
            options = "grp:win_space_toggle";
          };

          touchpad = {
            tap = true;
            natural-scroll = true;
            #dwt = true;
          };
        };

        outputs = {
          "HDMI-A-1" = {
            mode.width = 1920;
            mode.height = 1080;
            mode.refresh = 120.000;
            #focus-at-startup = true;
            position.x = 0;
            position.y = 0;
            variable-refresh-rate = "on-demand";
          };
          "DP-1" = {
            mode.width = 1920;
            mode.height = 1080;
            mode.refresh = 74.973;
            variable-refresh-rate = "on-demand";
          };
        };

        environment = {
          DISPLAY = ":0";
        };

        prefer-no-csd = true;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Layout
        layout = {
          gaps = 6;

          center-focused-column = "on-overflow";

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
            #urgent.color = config.modules.desktop.themes.niri.alert;
          };

          shadow = {
            enable = true;
          };
        };

        hotkey-overlay.skip-at-startup = true;

        screenshot-path = null;

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Animations
        animations = {
          window-resize = {
            custom-shader = ''
              vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;

                vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
                vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;

                // We can crop if the current window size is smaller than the next window
                // size. One way to tell is by comparing to 1.0 the X and Y scaling
                // coefficients in the current-to-next transformation matrix.
                bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
                bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;

                vec3 coords = coords_stretch;
                if (can_crop_by_x)
                  coords.x = coords_crop.x;
                if (can_crop_by_y)
                  coords.y = coords_crop.y;

                vec4 color = texture2D(niri_tex_next, coords.st);

                // However, when we crop, we also want to crop out anything outside the
                // current geometry. This is because the area of the shader is unspecified
                // and usually bigger than the current geometry, so if we don't fill pixels
                // outside with transparency, the texture will leak out.
                //
                // When stretching, this is not an issue because the area outside will
                // correspond to client-side decoration shadows, which are already supposed
                // to be outside.
                if (can_crop_by_x && (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x))
                  color = vec4(0.0);
                if (can_crop_by_y && (coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y))
                  color = vec4(0.0);

                return color;
              }
            '';
          };

          window-close = {
            kind.easing = {
              curve = "linear";
              duration-ms = 600;
            };
            custom-shader = ''
              vec4 fall_and_rotate(vec3 coords_geo, vec3 size_geo) {
                float progress = niri_clamped_progress * niri_clamped_progress;
                vec2 coords = (coords_geo.xy - vec2(0.5, 1.0)) * size_geo.xy;
                coords.y -= progress * 1440.0;
                float random = (niri_random_seed - 0.5) / 2.0;
                random = sign(random) - random;
                float max_angle = 0.5 * random;
                float angle = progress * max_angle;
                mat2 rotate = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
                coords = rotate * coords;
                coords_geo = vec3(coords / size_geo.xy + vec2(0.5, 1.0), 1.0);
                vec3 coords_tex = niri_geo_to_tex * coords_geo;
                vec4 color = texture2D(niri_tex, coords_tex.st);

                return color;
              }

              vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return fall_and_rotate(coords_geo, size_geo);
              }
            '';
          };
        };

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules
        window-rules = [
          {
            matches = [
              { app-id = "^org\.wezfurlong\.wezterm$"; }
              { app-id = "^clipse$"; }
            ];
            default-column-width = {};
          }
          {
            geometry-corner-radius = allCorners 10.0;
            clip-to-geometry = true;
          }
          # colors
          {
            matches = [
              { is-window-cast-target = true; }
            ];
            border = {
              inactive.color = config.modules.desktop.themes.niri.highlight;
            };
          }
          {
            matches = [
              { is-window-cast-target = true; }
            ];
            border = {
              inactive.color = config.modules.desktop.themes.niri.highlight;
            };
          }
          # highlight
          {
            matches = [
              { app-id = "^clipse$"; }
              { app-id = "^dde-polkit-agent$"; }
              { app-id = "^org\.gnome\.Loupe$"; }
              { title = "^Open Folder$"; }
              { title = "^Open File$"; }
              { title = "^Open$"; }
              #{ app-id = "^rofi-rbw$"; }
            ];
            open-floating = true;
            focus-ring = {
              # fog of war type effect
              enable = true;
              width = 4000;
              active.color = "#00000065";
              inactive.color = "#00000065";
            };
          }
          {
            matches = [
              { app-id = "^clipse$"; }
              { app-id = "^dde-polkit-agent$"; }
              #{ app-id = "^rofi-rbw$"; }
            ];
            block-out-from = "screen-capture";
          }
          # pip type stuff
          {
            matches = [
              { app-id = "firefox$"; title = "^Picture-in-Picture$"; }
              { title = "^Picture in picture$"; }
              { title = "^Discord Popout$"; }
            ];
            open-floating = true;
            default-floating-position = {
              x = 32;
              y = 32;
              relative-to = "top-right";
            };
          }
          # popups, dialogs, etc
          {
            matches = [
              { app-id = "^file-roller$"; }
              { app-id = "^org\.gnome\.FileRoller$"; }
              { app-id = "^org\.gnome\.Loupe$"; }
              { title = "^Open Folder$"; }
              { title = "^Open File$"; }
              { title = "^Open$"; }
              { app-id = "^dde-polkit-agent$"; }
            ];
            open-floating = true;
            default-column-width.proportion = 0.6;
            default-window-height.proportion = 0.8;
          }
          {
            matches = [
              { app-id = "^zenity$"; }
            ];
            open-floating = true;
          }
          {
            matches = [{ app-id = "^notitg-"; }];
            open-floating = true;
            min-width = 1280;
            max-width = 1280;
            min-height = 720;
            max-height = 720;
          }
          {
            matches = [{ app-id = "^notitg-"; title = "Loading..."; }];
            open-floating = true;
            min-width = 499;
            max-width = 499;
            min-height = 178;
            max-height = 178;
          }
          {
            matches = [{ app-id = "^notitg-"; title = "Whoops! NotITG Has Crashed!"; }];
            open-floating = true;
            min-width = 600;
            max-width = 600;
            min-height = 460;
            max-height = 460;
          }
        ];

        layer-rules = [
          {
            matches = [
              { namespace = "^notifications$"; }
            ];
            block-out-from = "screencast";
          }
          {
            matches = [
              { namespace = "^launcher$"; }
            ];
            shadow = {
              enable = true;
            };
            geometry-corner-radius = allCorners 10.0;
          }
          # for swaybg
          {
            matches = [
              { namespace = "^wallpaper$"; }
            ];
            place-within-backdrop = true;
          }
        ];

        # https://github.com/YaLTeR/niri/wiki/Configuration:-Key-Bindings
        binds = with config.hm.lib.niri.actions; let
          sh = spawn "sh" "-c";
        in {
          "Mod+Shift+Slash".action = show-hotkey-overlay;

          "Mod+D".action = spawn "fuzzel";

          "Mod+Q".action = close-window;

          "Mod+H".action = toggle-window-floating;

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

          # "Mod+J".action     = focus-window-or-workspace-down;
          # "Mod+K".action     = focus-window-or-workspace-up;
          # "Mod+Ctrl+J".action     = move-window-down-or-to-workspace-down;
          # "Mod+Ctrl+K".action     = move-window-up-or-to-workspace-up;

          "Mod+Home".action = focus-column-first;
          "Mod+End".action  = focus-column-last;
          "Mod+Shift+Home".action = move-column-to-first;
          "Mod+Shift+End".action  = move-column-to-last;

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

          "Mod+Page_Down".action      = focus-workspace-down;
          "Mod+Page_Up".action        = focus-workspace-up;
          #"Mod+U".action              = focus-workspace-down;
          #"Mod+I".action              = focus-workspace-up;
          "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
          "Mod+Shift+Page_Up".action   = move-column-to-workspace-up;
          #"Mod+Ctrl+U".action         = move-column-to-workspace-down;
          #"Mod+Ctrl+I".action         = move-column-to-workspace-up;

          "Mod+Ctrl+Page_Down".action = move-workspace-down;
          "Mod+Ctrl+Page_Up".action   = move-workspace-up;
          #"Mod+Shift+U".action         = move-workspace-down;
          #"Mod+Shift+I".action         = move-workspace-up;

          "Mod+Comma".action  = consume-window-into-column;
          "Mod+Period".action = expel-window-from-column;

          "Mod+BracketLeft".action  = consume-or-expel-window-left;
          "Mod+BracketRight".action = consume-or-expel-window-right;

          "Mod+R".action = switch-preset-column-width;
          "Mod+Shift+R".action = switch-preset-window-height;
          "Mod+Ctrl+R".action = reset-window-height;
          "Mod+J".action = toggle-column-tabbed-display;
          "Mod+F".action = maximize-column;
          "Mod+U".action = expand-column-to-available-width;
          "Mod+Shift+F".action = fullscreen-window;
          "Mod+Ctrl+Shift+F".action = toggle-windowed-fullscreen;
          "Mod+C".action = center-column;

          "Mod+W".action = set-dynamic-cast-window;
          "Mod+Ctrl+W".action = set-dynamic-cast-window;

          "Mod+Minus".action = set-column-width "-10%";
          "Mod+Equal".action = set-column-width "+10%";

          "Mod+Shift+Minus".action = set-window-height "-10%";
          "Mod+Shift+Equal".action = set-window-height "+10%";

          "Print".action = screenshot;
          #"Ctrl+Print".action = screenshot-screen;
          "Alt+Print".action = screenshot-window;

          "Mod+Shift+E".action = quit;

          "XF86AudioMicMute".action     = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle";
          "XF86AudioMicMute".allow-when-locked = true;

          "XF86Launch1".action = sh "${lib.getExe pkgs.rofi-rbw-wayland} -a copy -t password --clear-after 20";

          "XF86AudioPrev".action = sh "${lib.getExe pkgs.playerctl} previous";
          "XF86AudioPlay".action = sh "${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioNext".action = sh "${lib.getExe pkgs.playerctl} next";

          #"Mod+V".action = sh "${lib.getExe pkgs.wezterm} start --class 'clipse' -e '${lib.getExe config.modules.desktop.clipse.package}'";
          "Mod+V".action = sh config.modules.desktop.cliphist.summonCmd;

          "Mod+T".action = spawn "wezterm";
          "Mod+E".action = spawn "nautilus";

          "Mod+Shift+S".action = sh "${lib.getExe pkgs.wtype} Kjdf8314jlfssf";
          "Mod+Shift+D".action = sh "${lib.getExe pkgs.wtype} Ykds1479ymdppr";

          "Mod+Escape".action = toggle-keyboard-shortcuts-inhibit;
        } // (lib.attrsets.listToAttrs (builtins.concatMap (i: with config.hm.lib.niri.actions; [
          {
            name = "Mod+${toString i}";
            value.action = focus-workspace i;
          }
          # FIXME: use the action directly once sodiboo/niri-flake#1018 is fixed.
          {
            name = "Mod+Shift+${toString i}";
            value.action = spawn [ (lib.getExe cfg.package) "msg" "action" "move-column-to-workspace" (toString i) ];
          }
        ]) (lib.range 1 9)))
        // (if config.modules.desktop.wob.enable then let
          wobSock = config.modules.desktop.wob.sockPath;
        in {
          "XF86AudioRaiseVolume".action = sh "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}";
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".action = sh "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}";
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".action        = sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 0 > ${wobSock}) || wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}";
          "XF86AudioMute".allow-when-locked = true;
          "XF86MonBrightnessUp".action = sh "${lib.getExe pkgs.brightnessctl} s +5% && ${lib.getExe pkgs.brightnessctl} -m | awk -F, '{ print $4 }' | sed 's/.$//' > ${wobSock}";
          "XF86MonBrightnessUp".allow-when-locked = true;
          "XF86MonBrightnessDown".action = sh "${lib.getExe pkgs.brightnessctl} s 5%- && ${lib.getExe pkgs.brightnessctl} -m | awk -F, '{ print $4 }' | sed 's/.$//' > ${wobSock}";
          "XF86MonBrightnessDown".allow-when-locked = true;
        } else (if config.modules.desktop.mako.osd then {
          "XF86AudioRaiseVolume".action = sh "${lib.getExe config.modules.desktop.mako.volumeScript} up";
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".action = sh "${lib.getExe config.modules.desktop.mako.volumeScript} down";
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".action        = sh "${lib.getExe config.modules.desktop.mako.volumeScript} mute";
          "XF86AudioMute".allow-when-locked = true;
          "XF86MonBrightnessUp".action = sh "${lib.getExe config.modules.desktop.mako.backlightScript} up";
          "XF86MonBrightnessUp".allow-when-locked = true;
          "XF86MonBrightnessDown".action = sh "${lib.getExe config.modules.desktop.mako.backlightScript} down";
          "XF86MonBrightnessDown".allow-when-locked = true;
        } else {
          "XF86AudioRaiseVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+";
          "XF86AudioRaiseVolume".allow-when-locked = true;
          "XF86AudioLowerVolume".action = spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-";
          "XF86AudioLowerVolume".allow-when-locked = true;
          "XF86AudioMute".action        = spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle";
          "XF86AudioMute".allow-when-locked = true;
          "XF86MonBrightnessUp".action = spawn (lib.getExe pkgs.brightnessctl) "s" "+5%";
          "XF86MonBrightnessUp".allow-when-locked = true;
          "XF86MonBrightnessDown".action = spawn (lib.getExe pkgs.brightnessctl) "s" "5%-";
          "XF86MonBrightnessDown".allow-when-locked = true;
        })) // (if config.modules.desktop.hyprlock.enable then {
          "XF86ScreenSaver".action = spawn "${lib.getExe config.modules.desktop.hyprlock.package}";
        } else {});
      };
    };
  };
}

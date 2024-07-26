{ inputs, lib, config, system, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.hyprland;
  hyprpkgs = inputs.hyprland.packages.${system};
in {
  options.modules.desktop.hyprland = {
    enable = mkEnableOption "Enable Hyprland, a dynamic tiling Wayland compositor based on wlroots that doesn't sacrifice on its looks";
    allowTearing = mkEnableOption "Enable tearing, reduces latency in games but unsupported on some GPUs";
    package = mkOption {
      type = types.package;
      default = hyprpkgs.hyprland;
      example = "pkgs.hyprland";
    };
    portalPackage = mkOption {
      type = types.package;
      default = hyprpkgs.xdg-desktop-portal-hyprland;
      example = "pkgs.xdg-desktop-portal-hyprland";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager.sessionPackages = [ cfg.package ];
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk cfg.portalPackage ];
      config = {
        common = {
          default = [ "hyprland" "gtk" ];

          # for flameshot to work
          # https://github.com/flameshot-org/flameshot/issues/3363#issuecomment-1753771427
          "org.freedesktop.impl.portal.Screencast" = "hyprland";
          "org.freedesktop.impl.portal.Screenshot" = "hyprland";
        };
      };
    };
    hm.wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      package = cfg.package;

      settings = let
        wobSock = config.modules.desktop.wob.sockPath;
      in {
        source = [];

        "$mod" = "SUPER";
        bindm = [
          # Move/resize windows with mod + LMB/RMB and dragging
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
        bindel = (if config.modules.desktop.wob.enable then [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}"
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} s +5% | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > ${wobSock}"
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} s 5%- | sed -En 's/.*\(([0-9]+)%\).*/\1/p' > ${wobSock}"
        ] else [
          ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%+"
          ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 10%-"
          ", XF86MonBrightnessUp, exec, ${lib.getExe pkgs.brightnessctl} s +5%"
          ", XF86MonBrightnessDown, exec, ${lib.getExe pkgs.brightnessctl} s 5%-"
        ]);
        bindl = ([
          ",switch:Lid Switch,exec,${lib.getExe config.modules.desktop.hyprlock.package}"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ] ++ (if config.modules.desktop.wob.enable then [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && (wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 0 > ${wobSock}) || wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g' > ${wobSock}"
        ] else [
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ]));
        bindr = [
          "SUPER, Super_L, exec, ${lib.getExe pkgs.nwg-drawer}"
        ];
        bind =
          [
            "$mod, R, exec, ${lib.getExe pkgs.rofi-wayland} -show run"
            ", Print, exec, ${lib.getExe pkgs.grimblast} --freeze copy area"
            #"$mod, T, exec, [float] ${lib.getExe pkgs.wezterm}"
            "$mod, T, exec, ${lib.getExe pkgs.wezterm}" # this does not work
            #"$mod, ;, exec, "
            "$mod, Q, killactive, "
            #"$mod, M, exit, "
            "$mod, F, togglefloating, "
            "$mod, P, pseudo, " # dwindle
            "$mod, J, togglesplit, " # dwindle

            # Move focus with mod + arrow keys
            "$mod, left, movefocus, l"
            "$mod, right, movefocus, r"
            "$mod, up, movefocus, u"
            "$mod, down, movefocus, d"

            # Example special workspace (scratchpad)
            "$mod, S, togglespecialworkspace, magic"
            "$mod SHIFT, S, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mod + scroll
            "$mod, mouse_down, workspace, e+1"
            "$mod, mouse_up, workspace, e-1"

            ", XF86Launch1, exec, ${lib.getExe pkgs.rofi-rbw-wayland} -a copy -t password --clear-after 20"
            ", XF86ScreenSaver, exec, ${lib.getExe config.modules.desktop.hyprlock.package}"

            "ALT, Tab, exec, ${lib.getExe pkgs.rofi-wayland} -show window"
          ]
          ++ (
            # workspaces
            # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
            builtins.concatLists (builtins.genList (
                x: let
                  ws = let
                    c = (x + 1) / 10;
                  in
                    builtins.toString (x + 1 - (c * 10));
                in [
                  "$mod, ${ws}, workspace, ${toString (x + 1)}"
                  "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                ]
              )
              10)
          );

        input = {
          kb_layout = "us,ru";
          kb_variant = "workman,";
          kb_options = "grp:alt_shift_toggle";
          touchpad = {
            disable_while_typing = false;
            natural_scroll = true;
          };

          follow_mouse = 1;

          sensitivity = 0; # -1.0 - 1.0, 0 means no modification.
        };

        # basically porting the default config for safety

        # See https://wiki.hyprland.org/Configuring/Monitors/
        monitor=",highrr,auto,auto";


        # See https://wiki.hyprland.org/Configuring/Keywords/ for more

        # Execute your favorite apps at launch
        # exec-once = waybar & hyprpaper & firefox

        exec-once = [
          "${lib.getExe pkgs.networkmanagerapplet}"
          "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"   # authentication prompts
          "${lib.getExe pkgs.wl-clip-persist} --clipboard primary" # to fix wl clipboards disappearing
        ];

        # Source a file (multi-file configs)
        # source = ~/.config/hypr/myColors.conf

        # Some default env vars.
        env = [
          "XCURSOR_THEME,${config.modules.desktop.themes.cursor.name}"
          "XCURSOR_SIZE,24"
        ];

        general = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          gaps_in = 6;
          gaps_out = 6;
          border_size = 1;
          no_border_on_floating = false;

          layout = "dwindle";

          resize_on_border = true;

          # https://wiki.hyprland.org/Configuring/Tearing/
          allow_tearing = cfg.allowTearing;
        };

        windowrulev2 = [
          # i think this only applies to proton
          "immediate, class:^steam_app_"
          "float, class:^steam_app_"

          "immediate, class:XDRV.x86_64"
          "fullscreen, class:XDRV.x86_64"

          # common popups
          "float, class:file-roller"
          "size 1100 730, class:file-roller"
          "float, class:org.gnome.Loupe"
          "size 1100 730, class:org.gnome.Loupe"
          "float, title:^Open Folder$"
          "size 1100 730, title:^Open Folder$"
          "float, title:^Open File$"
          "size 1100 730, title:^Open File$"
          "float, class:zenity"

          # stepmania is a crusty old engine and likes to mess w/ fullscreening upon launch
          "suppressevent maximize, class:notitg-v4.3.0.exe"
          "suppressevent fullscreen, class:notitg-v4.3.0.exe"

          # generic wine stuff
          "float, class:\.exe$"
          # doesn't look great w/ wine's window decorations
          "rounding 0, class:\.exe$"
          
          #"float, class:org.gnome.Nautilus"

          # fix focus
          "stayfocused, class:^pinentry-"
          "stayfocused, class:^rofi"

          # workspace moving
          "workspace 1 silent, class:^vivaldi"
          "workspace 2 silent, class:code-url-handler"
          "workspace 4 silent, class:ArmCord"
        ];

        blurls = [
          "gtk-layer-shell"
        ];

        layerrule = [
          "blur,notifications"
          "blur,wob"
        ];

        decoration = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more

          rounding = 10;
            
          blur = {
            enabled = true;
            size = 4;
            passes = 1;
            #popups = true;
          };

          drop_shadow = false;
          #shadow_range = 4;
          #shadow_render_power = 3;

          # mistake mistake mistkae mistake mistake mistake mistake mistake mistake mistake
          #screen_shader = toString ../../config/analys.frag;
        };

        animations = {
          enabled = true;

          # https://wiki.hyprland.org/Configuring/Animations/

          bezier = [
            "outCubic, 0.33, 1, 0.68, 1"
            "outExpo, 0.16, 1, 0.3, 1"
          ];

          animation = [
            "windows, 1, 5, outExpo, popin"
            "windowsOut, 1, 5, outCubic, popin 80%"
            "border, 1, 2, outExpo"
            "fade, 1, 3, outCubic"
            "workspaces, 1, 6, outExpo"
            "specialWorkspace, 1, 2, outCubic, fade"
          ];
        };

        dwindle = {
          # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
          pseudotile = "yes"; # master switch for pseudotiling. Enabling is bound to mod + P in the keybinds section below
          preserve_split = "yes"; # you probably want this
        };

        master = {
          # See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
          new_is_master = true;
        };

        gestures = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          workspace_swipe = true;
        };

        misc = {
          # See https://wiki.hyprland.org/Configuring/Variables/ for more
          force_default_wallpaper = 0; # Set to 0 to disable the anime mascot wallpapers
          disable_splash_rendering = true;
          disable_hyprland_logo = true;
          vrr = 2;
        };

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        # windowrulev2 = float,class:^(kitty)$,title:^(kitty)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
      };
    };
  };
}

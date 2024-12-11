{ lib, config, pkgs, inputs, system, ... }:

with lib;
let
  cfg = config.modules.desktop.waybar;
in {
  options.modules.desktop.waybar = {
    enable = mkEnableOption "Enable Waybar, a highly customizable Wayland bar";
    package = mkOption {
      type = types.package;
      default = inputs.waybar.packages.${system}.default;
      example = "pkgs.waybar";
    };
  };

  config = mkIf cfg.enable {
    modules.desktop.execOnStart = [ "${lib.getExe cfg.package}" ];
    hm.programs.waybar = {
      enable = true;
      package = cfg.package;
      settings = let
        window = {
          format = "{}";
          icon = true;
          icon-size = 16;
          rewrite = {
            "(.*) - Vivaldi" = "$1";
            "(.*) - Visual Studio Code" = "$1";
            #"(.*\\.nix\\s.*)" = "";
            "(\\S+\\.js\\s.*)" = " $1";
            "(\\S+\\.ts\\s.*)" = " $1";
            "(\\S+\\.go\\s.*)" = " $1";
            "(\\S+\\.lua\\s.*)" = " $1";
            "(\\S+\\.java\\s.*)" = " $1";
            "(\\S+\\.rb\\s.*)" = " $1";
            "(\\S+\\.php\\s.*)" = " $1";
            "(\\S+\\.jsonc?\\s.*)" = " $1";
            "(\\S+\\.md\\s.*)" = " $1";
            "(\\S+\\.txt\\s.*)" = " $1";
            "(\\S+\\.cs\\s.*)" = " $1";
            "(\\S+\\.c\\s.*)" = " $1";
            "(\\S+\\.cpp\\s.*)" = " $1";
            "(\\S+\\.hs\\s.*)" = " $1";
            ".*Discord | (.*) | .*" = "$1 - ArmCord";
            #"(.*) - ArmCord" = "$1";
          };
          separate-outputs = true;
        };
        workspaces = {
          format = "{icon}";
          format-icons = {
            "1" = "";
            "2" = "";
            "3" = "";
            "4" = "";
            urgent = "";
            default = "•";
          };
          persistent-workspaces = {
            "1" = [];
            "2" = [];
            "3" = [];
            "4" = [];
          };
        };
        language = {
          format = " {}";
          format-en = "Aa";
          format-ru = "Ру";
          on-click = "hyprctl switchxkblayout at-translated-set-2-keyboard next";
          tooltip = true;
          tooltip-format = "{flag} {long}";
        };
      in {
        mainBar = {
          layer = "top";
          position = "top";
          #spacing = 4;
          height = 28;
          margin-top = 6;
          margin-left = 6;
          margin-right = 6;
          margin-bottom = 0;
          modules-left = [
            "image#logo"
            "hyprland/workspaces"
            "hyprland/window"
            "niri/workspaces"
            "niri/window"
          ];
          modules-center = [
            "clock"
          ];
          modules-right = [
            "group/playback"
            "group/status"
            "tray"
            "group/power"
          ];

          "group/playback" = {
            orientation = "inherit";
            modules = [
              "mpris"
            ];
          };

          "group/status" = {
            orientation = "inherit";
            modules = [
              "hyprland/language"
              "niri/language"
              "pulseaudio"
              "backlight"
              "cpu"
              "memory"
              "power-profiles-daemon"
              "battery"
              "custom/weather"
              "privacy"
              "custom/wallpaper"
              #"network"
            ];
          };
          "group/power" = {
            orientation = "inherit";
            modules = [
              "custom/power"
            ];
          };
          "custom/power" = let
            closeCmd = "${config.modules.desktop.hyprland.package}/bin/hyprctl dispatch exit}";
            powerSelect = pkgs.writeScript "power-menu" ''
              cmd=$(echo 'shutdown|reboot|suspend|lock|exit' | rofi -dmenu -sep '|' -i -p 'what to do ?' -theme-str 'window { height: 148px; }')
              case "$cmd" in
                shutdown)
                  shutdown now
                  ;;
                reboot)
                  reboot
                  ;;
                suspend)
                  systemctl suspend
                  ;;
                lock)
                  ${lib.getExe config.modules.desktop.hyprlock.package}
                  ;;
                "exit")
                  ${closeCmd}
                  ;;
              esac
            '';
          in {
            format = "⏻";
            tooltip = true;
            tooltip-format = "Power menu";
            on-click = "${powerSelect}";
          };
          "custom/wallpaper" = {
            format = "";
            tooltip = false;
            on-click = "${config.modules.desktop.swww.swapScript}";
          };
          "image#logo" = {
            path = ../../packages/iterator-icons/icons/color-seven-red-suns.png;
            size = 20;
            tooltip = false;
            interval = 0;
          };
          "hyprland/workspaces" = workspaces;
          #"niri/workspaces" = workspaces; # niri workspaces are kind of silly
          "hyprland/window" = window;
          "niri/window" = window;
          "hyprland/language" = language;
          "niri/language" = language;
          mpris = {
            format = "♫ {dynamic}";
            format-paused = "{status_icon} {dynamic}";
            dynamic-order = [ "title" ];
            tooltip-format = "{player}: {dynamic}";
            interval = 1;
            status-icons = {
		          playing = "▶";
              paused = "⏸";
            };
            player = "tauon"; # setting it to the default breaks it ?
          };
          pulseaudio = {
            format = "{icon} {volume}%";
            format-bluetooth = "{icon} {volume}%";
            format-muted = "婢 {volume}%";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            scroll-step = 1;
            on-click = "${lib.getExe pkgs.pavucontrol}";
            ignored-sinks = ["Easy Effects Sink"];
          };
          backlight = {
            format = "{icon} {percent}%";
            format-icons = ["" ""];
            scroll-step = 1;
          };
          cpu = {
            interval = 4;
            format = " {usage}%";
          };
          memory = {
            interval = 4;
            format = " {percentage}%";
            tooltip-format = "{used:0.1f}GiB/{avail:0.1f}GiB used\n{swapUsed:0.1f}GiB/{swapAvail:0.1f}GiB swap";
          };
          "battery" = {
            interval = 30;
            states = {
              warning = 20;
              critical = 10;
            };
            full-at = 98;
            format = "{icon} {capacity}%";
            format-icons = ["" "" "" "" ""];
            format-critical = " {capacity}%";
            tooltip-format = "{timeTo} ({power}W)";
            format-charging = " {capacity}%";
          };
          "network" = {
            format = "";
            format-ethernet = "";
            format-wifi = " {signalStrength}%";
            format-disconnected = "";
            tooltip-format = "{ifname} via {gwaddr}";
            tooltip-format-wifi = "connected to {essid}";
            tooltip-format-ethernet = "{ifname}";
            tooltip-format-disconnected = "Disconnected";
          };
          "clock" = {
            format = "{:%H:%M}";
            format-alt = "{:%a %b %d %R}";
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            calendar = {
              mode = "year";
              mode-mon-col = 3;
              weeks-pos = "right";
              on-scroll = 1;
              on-click-right = "mode";
              format = {
                months = "<span color='#ffead3'><b>{}</b></span>";
                days = "<span color='#ecc6d9'><b>{}</b></span>";
                weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                today = "<span color='#ff6699'><b><u>{}</u></b></span>";
              };
              actions = {
                on-click-right = "mode";
                on-click-forward = "tz_up";
                on-click-backward = "tz_down";
                on-scroll-up = "shift_up";
                on-scroll-down = "shift_down";
              };
            };
          };
          privacy = {
            icon-spacing = 0;
            icon-size = 12;
            transition-duration = 250;
            modules = [
              { type = "screenshare"; }
              { type = "audio-in"; }
            ];
          };
          power-profiles-daemon = {
            format = "{icon}";
            tooltip-format = "Power profile: {profile}\nDriver: {driver}";
            tooltip = true;
            format-icons = {
              default = "";
              performance = " perf";
              balanced = " balance";
              power-saver = " save";
            };
          };
          tray = {
            icon-size = 16;
            spacing = 4;
          };
          "custom/weather" = {
            format = "{}°";
            tooltip = true;
            interval = 3600;
            exec = "${lib.getExe pkgs.wttrbar} --location 'Moscow, Russia' --hide-conditions";
            return-type = "json";
          };
        };
      };
    };
  };
}
{ lib, config, inputs, system, ... }:

with lib;
let
  cfg = config.modules.desktop.hyprlock;
in {
  options.modules.desktop.hyprlock = {
    enable = mkEnableOption "Enable hyprlock, a simple, yet fast, multi-threaded and GPU-accelerated screen lock for hyprland";
    package = mkOption {
      type = types.package;
      default = inputs.hyprlock.packages.${system}.hyprlock;
      example = "pkgs.hyprlock";
    };
  };

  config = mkIf cfg.enable {
    security.pam.services.hyprlock.text = "auth include login";
    powerManagement.resumeCommands = ''
      ${lib.getExe cfg.package}
    '';
    hm.programs.hyprlock = with config.colorScheme.palette; {
      enable = true;
      package = cfg.package;
      settings = {
        general = {
          hide_cursor = false;
          no_fade_in = true;
          no_fade_out = true;
        };
        background = [
          {
            path = toString ../../assets/lockscreen.png;
            blur_passes = 3;
            blur_size = 6;
          }
        ];
        label = [
          {
            position = "0, 80";
            text = "cmd[update:1000] echo \"$(date +'%H:%M')\"";
            font_size = 48;
            color = "rgb(${base05})";
            font_family = config.modules.desktop.fonts.fonts.sansSerif.family;
            halign = "center"; valign = "center";
          }
          {
            position = "0, 30";
            text = "cmd[update:1000] echo \"$(date +'%A %B %e')\"";
            font_size = 14;
            color = "rgb(${base05})";
            font_family = config.modules.desktop.fonts.fonts.sansSerif.family;
            halign = "center"; valign = "center";
          }
          {
            position = "10, 10";
            halign = "left"; valign = "bottom";
            color = "rgb(${base05})";
            font_size = 8;
            font_family = config.modules.desktop.fonts.fonts.sansSerif.family;
            text = "$LAYOUT";
          }
        ];
        input-field = [
          {
            position = "0, -40";
            size = "280, 48";
            outline_thickness = 2;
            dots_size = 0.2;
            fade_on_empty = false;
            placeholder_text = "";

            outer_color = "rgb(${base0E})";
            inner_color = "rgb(${base00})";
            font_color = "rgb(${base05})";
            check_color = "rgb(${base02})";
            fail_color = "rgb(${base08})";
            capslock_color = "rgb(${base09})";
          }
        ];
      };
    };
  };
}
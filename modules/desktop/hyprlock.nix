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
    hm.home.packages = [ cfg.package ];
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
          no_fade_out = false;
        };
        background = [
          {
            path = toString ../../assets/lockscreen.png;
            blur_passes = 3;
            blur_size = 6;
          }
        ];
        shape = [
          {
            size = "280, 280";
            color = "rgb(${base00})";
            rounding = 48;

            position = "0, 45";
            halign = "center"; valign = "center";

            shadow_passes = 3;
            shadow_size = 8;
          }
        ];
        label = [
          {
            position = "0, 105";
            text = "cmd[update:1000] echo \"<span font_weight='1000'>$(date +'%H')</span>\"";
            font_size = 78;
            color = "rgb(eba0ac)"; # mauve
            font_family = "Inter";
            halign = "center"; valign = "center";
          }
          {
            position = "0, 20";
            text = "cmd[update:1000] echo \"<span font_weight='1000'>$(date +'%M')</span>\"";
            font_size = 78;
            color = "rgb(${base05})";
            font_family = "Inter";
            halign = "center"; valign = "center";
          }
          {
            position = "0, -45";
            text = "cmd[update:1000] echo \"$(date +'%A, %d %B')\"";
            font_size = 14;
            color = "rgb(${base05})";
            font_family = "Inter";
            halign = "center"; valign = "center";
          }
          {
            position = "0, 10";
            halign = "center"; valign = "bottom";
            color = "rgb(9399b2)";
            font_size = 8;
            font_family = "Inter";
            text = "$LAYOUT";
          }
          {
            position = "-15, -13";
            halign = "right"; valign = "top";
            color = "rgb(ffffff)";
            font_size = 14;
            font_family = "Font Awesome 6 Free";
            text = "";

            shadow_passes = 3;
            shadow_size = 8;
          }
          {
            position = "-41, -10";
            halign = "right"; valign = "top";
            color = "rgb(ffffff)";
            font_size = 14;
            font_family = "Inter";
            text = "cmd[update:4000] echo \"<span font_weight='600'>$(cat /sys/class/power_supply/BAT0/capacity)%</span>\"";

            shadow_passes = 3;
            shadow_size = 8;
          }
        ];
        input-field = [
          {
            position = "0, -140";
            size = "280, 48";
            outline_thickness = 2;
            dots_size = 0.3;
            fade_on_empty = false;
            placeholder_text = "";

            outer_color = "rgb(${base00})";
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
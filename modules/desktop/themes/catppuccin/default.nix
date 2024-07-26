{ inputs, config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.themes;
  accent = "pink";
  variant = "mocha";
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;
in {
  config = mkIf (cfg.active == "catppuccin") {
    colorScheme = colorScheme;

    modules.desktop.themes = {
      dark = true;

      gtkTheme = {
        name = "Catppuccin-Mocha-Compact-Pink-Dark"; #todo put accent in here
        package = pkgs.catppuccin-gtk.override {
          variant = variant;
          accents = [ accent ];
          tweaks = ["rimless"];
          size = "compact";
        };
      };

      iconTheme = {
        name = "WhiteSur-dark";
        package = pkgs.whitesur-icon-theme;
      };

      cursor = {
        package = pkgs.graphite-cursors;
        name = "graphite-dark";
      };

      sddmTheme = {
        name = "catppuccin-sddm-corners";
        package = (pkgs.my.catppuccin-sddm-corners.override {
          config.General = {
            Background = ../../../../assets/lockscreen.png;
            Font = config.modules.desktop.fonts.fonts.sansSerif.family;
          };
        });
      };

      editor = {
        vscode = {
          name = "Catppuccin Mocha";
          extension = (pkgs.vscode-extensions.catppuccin.catppuccin-vsc.override {
            accent = accent;
            boldKeywords = false;
            italicComments = false;
            italicKeywords = false;
            extraBordersEnabled = false;
            workbenchMode = "flat";
            #bracketMode = "rainbow";
          });
        };
      };

      hyprland = {
        source = "${inputs.hyprland-catppuccin}/themes/${variant}.conf";
        extraConfig = ''
          general {
            col.active_border=''$${accent}
            col.inactive_border=$surface0
          }
          decoration {
            col.shadow=$surface0
            col.shadow_inactive=$surface0
          }
          misc {
            background_color=$crust
          }
        '';
      };

      waybar = builtins.concatStringsSep "\n" [
        "@import \"${inputs.waybar-catppuccin}/themes/${variant}.css\";"
        (lib.readFile ./waybar.css)
      ];

      wob = with colorScheme.palette; {
        borderColor = "${base04}FF";
        backgroundColor = "${base01}66";
        barColor = "${base05}FF";
      };

      rofi = ./rofi.rasi;
    };
  };
}
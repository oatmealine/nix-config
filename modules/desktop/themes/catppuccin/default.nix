{ inputs, config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.themes;
  accent = "rosewater"; # rosewater, flamingo, pink, mauve, red, maroon, peach, yellow, green, teal, sky, sapphire, blue, lavender
  variant = "mocha"; # mocha, macchiato, frappe, latte
  colorScheme = inputs.nix-colors.colorSchemes.${"catppuccin-${variant}"};
  pascalCase = s: (toUpper (substring 0 1 s)) + (toLower (substring 1 (stringLength s) s));
in {
  config = mkIf (cfg.active == "catppuccin") {
    colorScheme = colorScheme;

    modules.desktop.themes = {
      dark = variant != "latte";

      gtkTheme = {
        name = "Catppuccin-${pascalCase variant}-Compact-${pascalCase accent}-Dark";
        package = pkgs.catppuccin-gtk.override {
          variant = variant;
          accents = [ accent ];
          tweaks = ["rimless"];
          size = "compact";
        };
      };

      qtTheme = {
        enable = true;
        name = "catppuccin-${variant}-${accent}";
        package = (pkgs.catppuccin-kvantum.override {
          variant = variant;
          accent = accent;
        });
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
          name = "Catppuccin ${pascalCase variant}";
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
        "@define-color accent @${accent};"
        (lib.readFile ./waybar.css)
      ];

      wob = with colorScheme.palette; {
        borderColor = "${base04}FF";
        backgroundColor = "${base01}66";
        barColor = "${base05}FF";
      };

      mako = with colorScheme.palette; {
        backgroundColor = "#${base00}FF";
        borderColor = "#${base00}FF";
        textColor = "#${base05}FF";
        progressColor = "#${base02}FF";
      };

      rofi = ./rofi.rasi;
      fuzzel = "${inputs.fuzzel-catppuccin}/themes/catppuccin-${variant}/${accent}.ini";

      wezterm = ''
        config.color_scheme = 'Catppuccin ${pascalCase variant}'
      '';

      niri = with colorScheme.palette; {
        # this sucks but i'd need to get a nix version of the colorscheme to fix this
        accent = "#${base06}";
        inactive = "#${base02}";
      };
    };
  };
}
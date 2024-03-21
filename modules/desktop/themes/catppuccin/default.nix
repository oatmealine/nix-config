{ inputs, config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.themes;
  accent = "pink";
  variant = "mocha";
in {
  config = mkIf (cfg.active == "catppuccin") {
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

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

      hyprland = "${inputs.hyprland-catppuccin}/themes/${variant}.conf";
    };
  };
}
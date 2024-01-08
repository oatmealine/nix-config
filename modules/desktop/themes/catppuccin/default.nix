{ inputs, config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.themes;
  #accent = "pink"; # TODO?
in {
  config = mkIf (cfg.active == "catppuccin") {
    colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

    modules.desktop.themes = {
      dark = true;

      gtkTheme = {
        name = "Catppuccin-Mocha-Compact-Pink-Dark";
        package = pkgs.catppuccin-gtk.override {
          variant = "mocha";
          accents = ["pink"];
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

      editor = {
        vscode = {
          name = "Catppuccin Mocha";
          extension = (pkgs.vscode-extensions.catppuccin.catppuccin-vsc.override {
            accent = "pink";
            boldKeywords = false;
            italicComments = false;
            italicKeywords = false;
            extraBordersEnabled = false;
            workbenchMode = "flat";
            #bracketMode = "rainbow";
          });
        };
      };
    };
  };
}
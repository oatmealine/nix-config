{ lib, config, inputs, pkgs, ... }:

with lib;
let
  cfg = config.gtkConfig;
  nix-colors-lib = inputs.nix-colors.lib.contrib { inherit pkgs; };
in {
  options.gtkConfig = {
    enable = mkEnableOption "Enable GTK configuration";
    cursor = mkOption {
      type = types.submodule {
        options = {
          package = mkOption { type = types.package; };
          name = mkOption { type = types.str; };
        };
      };
    };
    icon = mkOption {
      type = types.submodule {
        options = {
          package = mkOption { type = types.package; };
          name = mkOption { type = types.str; };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    gtk = {
      enable = true;
      cursorTheme = cfg.cursor;
      iconTheme = cfg.icon;
      font = {
        package = config.opinions.fonts.regular.package;
        name = config.opinions.fonts.regular.family;
        size = config.opinions.fonts.regular.size;
      };
      theme = {
        package = nix-colors-lib.gtkThemeFromScheme { scheme = config.colorScheme; };
        name = config.colorScheme.slug;
      };
    };
  };
}
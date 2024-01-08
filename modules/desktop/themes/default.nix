{ lib, config, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.themes;
in {
  options.modules.desktop.themes = with types; {
    active = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Name of the theme to apply; see modules/desktop/themes for a list of valid options";
    };

    dark = mkOpt bool false;

    gtkTheme = {
      name = mkOpt str "";
      package = mkPackageOption pkgs "gtk" {};
    };
    iconTheme = {
      name = mkOpt str "";
      package = mkPackageOption pkgs "icon" {};
    };
    cursor = {
      name = mkOpt str "";
      package = mkPackageOption pkgs "cursor" {};
    };

    editor = {
      vscode = {
        name = mkOpt str "";
        extension = mkPackageOption pkgs "extension" {};
      };
    };
  };

  config = mkIf (cfg.active != null) {
    programs.dconf.enable = true;

    hm.dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = mkIf cfg.dark "prefer-dark";
    };

    hm.gtk = {
      enable = true;
      cursorTheme = cfg.cursor;
      iconTheme = cfg.iconTheme;
      theme = cfg.gtkTheme;
    };

    hm.programs.vscode = {
      extensions = [ cfg.editor.vscode.extension ];
      userSettings = {
        "workbench.colorTheme" = cfg.editor.vscode.name;
      };
    };
  };
}
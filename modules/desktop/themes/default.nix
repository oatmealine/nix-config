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
    sddmTheme = {
      name = mkOpt str "";
      package = mkPackageOption pkgs "catppuccin-sddm-corners" {};
    };

    editor = {
      vscode = {
        name = mkOpt str "";
        extension = mkPackageOption pkgs "extension" {};
      };
    };

    hyprland = mkOpt (nullOr str) null;
  };

  config = mkIf (cfg.active != null) {
    programs.dconf.enable = true;

    hm.dconf = {
      enable = true;
      settings."org/gnome/desktop/interface".color-scheme = mkIf cfg.dark "prefer-dark";
      settings."org/gnome/desktop/interface".gtk-theme = cfg.gtkTheme.name;
      settings."org/gnome/desktop/interface".icon-theme = cfg.iconTheme.name;
      settings."org/gnome/desktop/interface".cursor-theme = cfg.cursor.name;

      settings."org/gnome/shell/extensions/user-theme".name = cfg.gtkTheme.name;
    };

    hm.gtk = {
      enable = true;
      cursorTheme = cfg.cursor;
      iconTheme = cfg.iconTheme;
      theme = cfg.gtkTheme;
    };

    hm.home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = cfg.cursor.name;
      package = cfg.cursor.package;
    };

    hm.services.dunst.iconTheme = {
      name = cfg.iconTheme.name;
      package = cfg.iconTheme.package;
    };

    hm.programs.vscode = {
      extensions = [ cfg.editor.vscode.extension ];
      userSettings = {
        "workbench.colorTheme" = cfg.editor.vscode.name;
      };
    };

    hm.wayland.windowManager.hyprland.settings.source = mkIf (cfg.hyprland != null) [ cfg.hyprland ];
  };
}
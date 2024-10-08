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

    hyprland = {
      source = mkOpt (nullOr str) null;
      extraConfig = mkOpt (nullOr str) null;
    };

    niri = {
      accent = mkOpt str "#7fc8ff";
      inactive = mkOpt str "#505050";
    };

    waybar = mkOpt str "";

    wob = {
      borderColor = mkOpt (nullOr str) null;
      backgroundColor = mkOpt (nullOr str) null;
      barColor = mkOpt (nullOr str) null;
    };

    rofi = mkOpt (nullOr path) null;
    fuzzel = mkOpt (nullOr str) null;

    wezterm = mkOpt (nullOr str) null;
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
      gtk3.extraConfig.gtk-application-prefer-dark-theme = mkIf cfg.dark "1";
      gtk4.extraConfig.gtk-application-prefer-dark-theme = mkIf cfg.dark "1";
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
      #userSettings = {
      #  "workbench.colorTheme" = cfg.editor.vscode.name;
      #};
    };

    hm.wayland.windowManager.hyprland = {
      settings.source = mkIf (cfg.hyprland.source != null) [ cfg.hyprland.source ];

      # this has to be done this way because source (on my end) is shoved at the bottom
      # which means the theme variables aren't loaded in the regular config.
      # luckily, extraConfig is always last
      # EDIT: no longer the case cus sources can be pushed to the top. too lazy to
      # fix, so leaving this as a
      # TODO
      extraConfig = mkIf (cfg.hyprland.extraConfig != null) cfg.hyprland.extraConfig;
    };

    hm.programs.waybar.style = cfg.waybar;

    hm.services.wob.settings."" = {
      border_color = cfg.wob.borderColor;
      background_color = cfg.wob.backgroundColor;
      bar_color = cfg.wob.barColor;
    };

    hm.programs.rofi.theme = cfg.rofi;
    hm.programs.fuzzel.settings.main = {
      include = cfg.fuzzel;
      icon-theme = cfg.iconTheme.name;
    };
  };
}
{ lib, config, ... }:

with lib;
with lib.my;
let
  cfg = config.modules.desktop.themes;
in {
  options.modules.desktop.themes = with types; {
    active = mkOption {
      type = nullOr str;
      default = null;
      description = "Name of the theme to apply; see modules/desktop/themes for a list of valid options";
    };

    dark = mkOpt bool false;

    gtkTheme = {
      name = mkOpt (nullOr str) null;
      package = mkOpt (nullOr package) null;
    };
    qtTheme = {
      enable = mkEnableOption "Set the qt5ct theme";
      name = mkOpt (nullOr str) null;
      package = mkOpt (nullOr package) null;
    };
    iconTheme = {
      name = mkOpt (nullOr str) null;
      package = mkOpt (nullOr package) null;
    };
    cursor = {
      name = mkOpt (nullOr str) null;
      package = mkOpt (nullOr package) null;
    };
    sddmTheme = {
      name = mkOpt (nullOr str) null;
      package = mkOpt (nullOr package) null;
    };

    editor = {
      vscode = {
        name = mkOpt (nullOr str) null;
        extension = mkOpt (nullOr package) null;
      };
    };

    mako = {
      backgroundColor = mkOpt str "#285577FF";
      borderColor = mkOpt str "#4C7899FF";
      textColor = mkOpt str "#FFFFFFFF";
      progressColor = mkOpt str "#5588AAFF";
    };

    hyprland = {
      source = mkOpt (nullOr str) null;
      extraConfig = mkOpt (nullOr str) null;
    };

    niri = {
      accent = mkOpt str "#7fc8ff";
      inactive = mkOpt str "#505050";
      alert = mkOpt str "#9b0000";
      highlight = mkOpt str "#9b0000";
      insert-hint = mkOpt str "#ffc87f80";
    };

    waybar = mkOpt str "";
    waybarTop = mkOpt str "";

    wob = {
      borderColor = mkOpt (nullOr str) null;
      backgroundColor = mkOpt (nullOr str) null;
      barColor = mkOpt (nullOr str) null;
    };

    rofi = mkOpt (nullOr path) null;
    fuzzel = mkOpt (nullOr str) null;

    wezterm = mkOpt (nullOr str) null;

    vicinae = {
      name = mkOpt (nullOr str) null;
      iconTheme = mkOpt (nullOr str) null;
    };
  };

  config = mkIf (cfg.active != null) (mkMerge [
    {
      programs.dconf.enable = true;

      hm.dconf = {
        enable = true;
        settings."org/gnome/desktop/interface".color-scheme = mkIf cfg.dark "prefer-dark";
        settings."org/gnome/desktop/interface".gtk-theme = mkIf (cfg.gtkTheme.name != null) cfg.gtkTheme.name;
        settings."org/gnome/desktop/interface".icon-theme = mkIf (cfg.iconTheme.name != null) cfg.iconTheme.name;
        settings."org/gnome/desktop/interface".cursor-theme = mkIf (cfg.cursor.name != null) cfg.cursor.name;

        settings."org/gnome/shell/extensions/user-theme".name = mkIf (cfg.gtkTheme.name != null) cfg.gtkTheme.name;
      };

      hm.gtk = {
        enable = true;
        cursorTheme = mkIf (cfg.cursor.name != null) cfg.cursor;
        iconTheme = mkIf (cfg.iconTheme.name != null) cfg.iconTheme;
        theme = mkIf (cfg.gtkTheme.name != null) cfg.gtkTheme;
        gtk3.extraConfig.gtk-application-prefer-dark-theme = mkIf cfg.dark "1";
        gtk4.extraConfig.gtk-application-prefer-dark-theme = mkIf cfg.dark "1";
      };

      hm.home.pointerCursor = mkIf (cfg.cursor.name != null) {
        gtk.enable = true;
        x11.enable = true;
        name = cfg.cursor.name;
        package = cfg.cursor.package;
      };

      hm.services.mako.settings = {
        icon-path = mkIf (cfg.iconTheme.name != null) "${cfg.iconTheme.package}/share/icons/${cfg.iconTheme.name}/";
        background-color = cfg.mako.backgroundColor;
        border-color = cfg.mako.borderColor;
        text-color = cfg.mako.textColor;
        progress-color = cfg.mako.progressColor;
      };

      hm.programs.vscode = {
        profiles.default.extensions = [ cfg.editor.vscode.extension ];
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

      # moved to waybar module
      #hm.programs.waybar.style = cfg.waybar;
      modules.desktop.waybar.style = cfg.waybar;
      modules.desktop.waybar.styleTop = cfg.waybarTop;

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

      hm.services.vicinae.settings.theme = let
        themeConf = {
          name = cfg.vicinae.name;
          iconTheme = cfg.vicinae.iconTheme;
        };
      in {
        light = themeConf;
        dark = themeConf;
      };
    }
    (mkIf cfg.qtTheme.enable {
      hm.qt = {
        enable = true;
        platformTheme.name = "qtct";
      };
      hm.home.packages = [ cfg.qtTheme.package ];
    })
  ]);
}
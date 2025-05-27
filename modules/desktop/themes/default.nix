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
    qtTheme = {
      enable = mkEnableOption "Set the qt5ct theme";
      name = mkOpt str "";
      package = mkPackageOption pkgs "qt" {};
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
  };

  config = mkIf (cfg.active != null) (mkMerge [
    {
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

      hm.services.mako = {
        iconPath = "${cfg.iconTheme.package}/share/icons/${cfg.iconTheme.name}/";
        backgroundColor = cfg.mako.backgroundColor;
        borderColor = cfg.mako.borderColor;
        textColor = cfg.mako.textColor;
        progressColor = cfg.mako.progressColor;
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
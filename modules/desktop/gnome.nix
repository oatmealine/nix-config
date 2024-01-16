{ config, lib, pkgs, ... }:

with lib;
with builtins;
let
  cfg = config.modules.desktop.gnome;
in {
  options.modules.desktop.gnome = {
    enable = mkEnableOption "Enable the Gnome desktop environment";
    extensions = mkOption {
      description = "Set a list of extensions to use";
      type = types.listOf types.package;
      default = with pkgs.gnomeExtensions; [
        rounded-window-corners
        force-quit
        pixel-saver
        status-area-horizontal-spacing
        weeks-start-on-monday-again
        user-themes
        espresso
        clipboard-indicator
        appindicator
        #blur-my-shell
        #dash-to-dock
        just-perfection
        disable-unredirect-fullscreen-windows
        #gsconnect
        launch-new-instance
      ];
    };
    keybinds = {
      shell = mkOption {
        description = ''Override Gnome shell keybindings (org/gnome/shell/keybindings/...)'';
        type = types.attrsOf (types.listOf types.str);
        example = ''{ screenshot = [ "<Ctrl>Print" ]; }'';
        default = {};
      };

      wm = mkOption {
        description = ''Override Gnome window manager keybindings (org/gnome/desktop/wm/keybindings/...)'';
        type = types.attrsOf (types.listOf types.str);
        example = ''{ panel-run-dialog = [ "<Primary>r" ]; }'';
        default = {};
      };

      mutter = mkOption {
        description = ''Override Mutter keybindings (org/gnome/mutter/keybindings/...)'';
        type = types.attrsOf (types.listOf types.str);
        example = ''{ rotate-monitor = [ "<Primary>l" ] }'';
        default = {};
      };

      custom = mkOption {
        type = types.attrsOf (types.submodule {
          options = {
            binding = mkOption {
              description = "The keybind combination to activate this binding";
              example = ''"<Primary><Alt>t"'';
            };
            command = mkOption {
              description = "The command to execute upon activation";
              example = ''"alacritty"'';
            };
          };
        });
        default = {};
      };
    };
  };

  config = mkIf cfg.enable {
    programs.dconf.enable = true;

    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.desktopManager.gnome.enable = true;

    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = mkForce (config.modules.desktop.envProto == "wayland");
    };

    services.gnome.games.enable = true;

    hm.home.packages = with pkgs; [
      dconf2nix
      gnome.gnome-disk-utility
      gnome.dconf-editor
      gnome.gnome-tweaks
      gedit
    ] ++ cfg.extensions;

    environment.gnome.excludePackages = with pkgs.gnome; [
      pkgs.gnome-tour
      #baobab
      epiphany
      pkgs.gnome-text-editor
      #gnome-calculator
      #gnome-calendar
      #gnome-characters
      #gnome-clocks
      pkgs.gnome-console
      gnome-contacts
      #gnome-font-viewer
      #gnome-logs
      gnome-maps
      gnome-music
      #gnome-system-monitor
      #gnome-weather
      #pkgs.loupe
      #nautilus
      pkgs.gnome-connections
      simple-scan
      pkgs.snapshot
      #totem
      yelp
      seahorse
      geary
    ];

    hm.dconf = let
      # [ binding ]
      customBindings = attrValues (mapAttrs (name: value: { name = name; binding = value.binding; command = value.command; }) cfg.keybinds.custom);
      # [ { key, binding } ]
      customBindingSets = imap0 (i: v: { name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}"; value = v; }) customBindings;
      # { key = binding }
      customBindingsAttr = listToAttrs customBindingSets;

      extensions = map (pkg: pkg.extensionUuid) cfg.extensions;
    in {
      settings = {
        "org/gnome/settings-daemon/plugins/media-keys" = {
          custom-keybindings = map (n: "/${n}/") (attrNames customBindingsAttr);
        };

        "org/gnome/shell/keybindings" = cfg.keybinds.shell;
        "org/gnome/desktop/wm/keybindings" = cfg.keybinds.wm;
        "org/gnome/mutter/keybindings" = cfg.keybinds.mutter;

        "org/gnome/shell".enabled-extensions = extensions;
      } // customBindingsAttr;
    };
  };
}
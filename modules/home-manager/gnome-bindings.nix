{ config, lib, ... }:

with lib;
let 
  cfg = config.gnomeBindings;
in {
  options.gnomeBindings = {
    enable = mkEnableOption "Enable Gnome bindings";

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

  config = mkIf cfg.enable (let
    # [ binding ]
    customBindings = attrValues (mapAttrs (name: value: { name = name; binding = value.binding; command = value.command; }) cfg.custom);
    # [ { key, binding } ]
    customBindingSets = imap0 (i: v: { name = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom${toString i}"; value = v; }) customBindings;
    # { key = binding }
    customBindingsAttr = listToAttrs customBindingSets;
  in {
    dconf.settings = {
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = map (n: "/${n}/") (attrNames customBindingsAttr);
      };

      "org/gnome/shell/keybindings" = cfg.shell;
      "org/gnome/desktop/wm/keybindings" = cfg.wm;
      "org/gnome/mutter/keybindings" = cfg.mutter;
    } // customBindingsAttr;
  });
}
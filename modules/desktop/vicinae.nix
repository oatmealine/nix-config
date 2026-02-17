{ lib, config, pkgs, inputs, system, ... }:

with lib;
let
  cfg = config.modules.desktop.vicinae;
in {
  options.modules.desktop.vicinae = {
    enable = mkEnableOption "Enable vicinae, a native, fast, extensible launcher for the desktop";
    package = mkOption {
      type = types.package;
      default = inputs.vicinae.packages.${system}.default;
    };
  };

  config = mkIf cfg.enable {
    hm.services.vicinae = {
      enable = true;
      package = cfg.package;
      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };

      settings = {
        # is this needed?
        "$schema" = "https://vicinae.com/schemas/config.json";

        pop_to_root_on_close = true;
        
        launcher_window = {
          opacity = 0.95;
          client_side_decorations.enabled = false;

          layer_shell = {
            enabled = true;
            keyboard_interactivity = "exclusive"; # 'exclusive' | 'on_demand'
            # either 'overlay' or 'top'.
            # Other layers are not supported as they are unsuitable for a launcher.
            # 'top' is recommended as using 'overlay' will make the vicinae window appear on top of IME popovers in some scenarios.
            layer = "top";
          };
        };

        favorites = [
          "core:search-emojis"
          "@knoopx/vicinae-extension-nix-0:packages"
          "clipboard:history"
        ];

        providers = {
          applications = {
            preferences = {
              defaultAction = "launch";
            };
          };
          files.enabled = false;
        };

        escape_key_behavior = "close_window";

        font = {
          normal = {
            family = "Recursive";
            size = 10.5;
          };
        };
      };

      extensions = with inputs.vicinae-extensions.packages.${system}; [
        mullvad
        niri
        nix
      ];
    };
  };
}
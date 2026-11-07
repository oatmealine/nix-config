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
      #default = pkgs.vicinae;
    };
  };

  config = mkIf cfg.enable {
    hm.programs.vicinae = {
      enable = true;
      package = cfg.package;
      systemd = {
        enable = true;
        autoStart = true;
        environment = {
          USE_LAYER_SHELL = 1;
          QSG_RHI_BACKEND = "vulkan";
          EMOJI_FONT = "Twemoji COLR";
        };
      };

      settings = {
        input_server.enabled = false; # doesn't work on nix anyways
        tray.enabled = false;

        font = {
          normal = {
            family = "Rec Mono Casual";
            size = 10.5;
          };
        };

        telemetry.system_info = false;

        pop_to_root_on_close = true;
        
        launcher_window = {
          opacity = 0.7;
          client_side_decorations.enabled = true;
          client_side_decorations.shadow_size = 0;
          layer_shell.enabled = true;
        };

        favorites = [
          "core:search-emojis"
          "@knoopx/vicinae-extension-nix-0:packages"
          "@knoopx/vicinae-extension-nix-0:options"
        ];

        providers = {
          browser-extension.enabled = false;
          developer.enabled = false;
          system.enabled = false;
          wm.enabled = false;
          power.enabled = false;
          
          core = {
            entrypoints = {
              sponsor.enabled = false;
            };
          };
          applications = {
            preferences = {
              defaultAction = "launch";
            };
          };
          files = {
            enabled = false;
            preferences.autoIndexing = false;
          };
          clipboard.preferences.eraseOnStartup = true;
        };

        escape_key_behavior = "close_window";
      };

      extensions = with inputs.vicinae-extensions.packages.${system}; [
        mullvad
        niri
        nix
      ];
    };
  };
}

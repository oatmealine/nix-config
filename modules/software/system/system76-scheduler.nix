{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.system76-scheduler;
in {
  options.modules.software.system.system76-scheduler = {
    enable = mkEnableOption "Enable System76 Scheduler, a scheduling service which optimizes Linux's CPU scheduler and automatically assigns process priorities for improved desktop responsiveness";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      services.system76-scheduler = {
        enable = true;

        useStockConfig = false;
        settings = {
          processScheduler = {
            # pipewire nice levels shoooould be handled by the pipewire module
            # just fine
            pipewireBoost.enable = false;
            foregroundBoost = {
              enable = true;
              foreground = {
                matchers = [
                  "alacritty"
                  "firefox"
                  "firefox-bin"
                  "browser"
                  "kitty"
                  "slack"
                  "thunderbird"
                  "vim"
                  "wineserver"
                  "services.exe"
                  "winedevice.exe"
                  "plugplay.exe"
                  "explorer.exe"
                  "svchost.exe"
                  "rpcss.exe"
                  "tf_linux64"
                  "code"
                  "vivaldi-bin"
                ];
              };
            };
          };
        };
        assignments = {
          # confine builders / compilers / LSP servers etc. to the "batch"
          # scheduling class automagically.  add matchers to taste!
          batch-passive = {
            class = "batch";
            matchers = [
              "rust-analyzer"
            ];
          };
          batch-active = {
            nice = 15;
            class = "batch";
            ioClass = "idle";
            matchers = [
              "bazel"
              "clangd"
              "nix-daemon"
              "nix"
            ];
          };
        };
        # do not disturb adults:
        exceptions = [
          "include descends=\"schedtool\""
          "include descends=\"nice\""
          "include descends=\"chrt\""
          "include descends=\"taskset\""
          "include descends=\"ionice\""

          "schedtool"
          "nice"
          "chrt"
          "ionice"

          "dbus"
          "dbus-broker"
          "rtkit-daemon"
          "taskset"
          "systemd"
        ];
      };
    }
    (mkIf config.modules.desktop.niri.enable {
      hm.services.system76-scheduler-niri.enable = true;
    })
  ]);
}
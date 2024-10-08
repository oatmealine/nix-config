{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.batsignal;
in {
  options.modules.desktop.batsignal = {
    enable = mkEnableOption "Enable batsignal, a battery notification service";
    package = mkOption {
      type = types.package;
      default = pkgs.batsignal;
    };
  };

  config = mkIf cfg.enable {
    modules.desktop.execOnStart = [
      # -w 20 -c 10 -d 5  --  set battery levels
      # -p                --  notify on plug/unplug
      # -m 2              --  set interval to 2 seconds
      "${lib.getExe cfg.package} -w 20 -c 10 -d 5 -p -m 2"
    ];
  };
}
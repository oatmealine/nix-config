{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.distractions.discord;
in {
  options.modules.software.distractions.discord = {
    enable = mkEnableOption "Enable Discord, a social messaging app";
  };

  config = mkIf cfg.enable {
    user.packages = let
      flags =
        [
          "--flag-switches-begin"
          "--flag-switches-end"
          "--disable-gpu-memory-buffer-video-frames"
          "--enable-accelerated-mjpeg-decode"
          "--enable-accelerated-video"
          "--enable-gpu-rasterization"
          "--enable-native-gpu-memory-buffers"
          "--enable-zero-copy"
          "--ignore-gpu-blocklist"
          "--disable-features=UseOzonePlatform"
          "--enable-features=VaapiVideoDecoder"
        ];
      discord = (pkgs.unstable.discord-canary.override {
        withOpenASAR = true;
        withVencord = true;	
      }).overrideAttrs (old: {
        preInstall = ''
          gappsWrapperArgs+=("--add-flags" "${concatStringsSep " " flags}")
        '';
      });
    in [ discord ];
  };
}
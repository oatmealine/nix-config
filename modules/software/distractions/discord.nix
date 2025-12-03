{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.distractions.discord;
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
      #"--disable-features=UseOzonePlatform"
      "--enable-features=VaapiVideoDecoder"
      "--enable-features=UseOzonePlatform"
      "--enable-features=WebRTCPipeWireCapturer"
      "--ozone-platform=wayland" # armcord specific
    ];
  vanillaDiscordPackage = pkgs.unstable.discord.override {
    withOpenASAR = cfg.openasar;
    withEquicord = true;
  };
  package = if cfg.armcord then pkgs.unstable.armcord else (if cfg.vesktop then pkgs.unstable.vesktop else vanillaDiscordPackage);
in {
  options.modules.software.distractions.discord = {
    enable = mkEnableOption "Enable Discord, a social messaging app";
    armcord = mkEnableOption "Use Armcord, an alternative Electron client";
    vesktop = mkEnableOption "Use Vesktop, an alternative Electron client with Vencord pre-installed";
    openasar = mkEnableOption "Enable OpenASAR, an alternative ASAR file for the official Discord client";
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.armcord && cfg.vesktop);
        message = "You must either enable Armcord or Vesktop, not both";
      }
    ];

    user.packages = [
      (if !cfg.vesktop then (package.overrideAttrs (old: {
        preInstall = ''
          gappsWrapperArgs+=("--add-flags" "${concatStringsSep " " flags}")
        '';
      })) else package)
    ];
  };
}
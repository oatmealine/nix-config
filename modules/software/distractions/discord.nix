{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.distractions.discord;
  features = [
    "UseOzonePlatform"
    "WebRTCPipeWireCapturer"
    "WebUIDarkMode"
    "WaylandWindowDecorations"
    "Vulkan"
    "SkiaGraphite"
    "VaapiVideoEncoder"
    "VaapiVideoDecoder"
    #"VaapiIgnoreDriverChecks"
    "CanvasOopRasterization"
    "OverlayScrollbar"
    "ParallelDownloading"
  ];
  flags = [
    "--use-vulkan=native"
    "--enable-dawn-backend=vulkan"
    "--ignore-gpu-blocklist"
    "--enable-gpu-rasterization"
    "--enable-zero-copy"
    "--enable-raw-draw"
    "--enable-drdc"
    "--disable-gpu-driver-bug-workarounds"

    "--enable-hardware-overlays"
    "--enable-accelerated-video-decode"
    "--enable-accelerated-video-encode"
    "--enable-accelerated-mjpeg-decode"
    "--enable-oop-rasterization"
    "--enable-webgl-developer-extensions"
    "--enable-accelerated-2d-canvas"
    "--enable-direct-composition"
    "--enable-gpu-compositing"

    "--enable-gpu"
    "--enable-features=${concatStringsSep "," features}"
    "--ozone-platform=wayland"
  ];
  vanillaDiscordPackage = cfg.package.override {
    withVencord = cfg.vencord.enable && !cfg.equicord.enable;
    vencord = cfg.vencord.package;
    withEquicord = cfg.vencord.enable && cfg.equicord.enable;
    equicord = cfg.equicord.equicordPackage;
    withOpenASAR = cfg.openasar.enable;
    openasar = cfg.openasar.package;
    commandLineArgs = concatStringsSep " " flags;
  };
  finalPackage =
    if cfg.legcord.enable then cfg.legcord.package else (
      if cfg.vesktop.enable then
        (if cfg.equicord.enable then cfg.equicord.equibopPackage else cfg.vesktop.package)
        else vanillaDiscordPackage
    );
in {
  options.modules.software.distractions.discord = {
    enable = mkEnableOption "Enable Discord, a social messaging app";
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.discord;
    };

    vencord = {
      enable = mkEnableOption "Enable Vencord, a Discord clientmod";
      package = mkOption {
        type = types.package;
        default = pkgs.unstable.vencord;
      };
    };
    legcord = {
      enable = mkEnableOption "Use Legcord, an alternative Electron client";
      package = mkOption {
        type = types.package;
        default = pkgs.unstable.legcord;
      };
    };
    vesktop = {
      enable = mkEnableOption "Use Vesktop, an alternative Electron client with Vencord pre-installed";
      package = mkOption {
        type = types.package;
        default = pkgs.unstable.vesktop;
      };
    };
    openasar = {
      enable = mkEnableOption "Enable OpenASAR, an alternative ASAR file for the official Discord client";
      package = mkOption {
        type = types.package;
        default = pkgs.unstable.openasar;
      };
    };
    equicord = {
      enable = mkEnableOption "Use Equicord instead of Vencord, and Equibop instead of Vesktop";
      equicordPackage = mkOption {
        type = types.package;
        default = pkgs.unstable.equicord;
      };
      equibopPackage = mkOption {
        type = types.package;
        default = pkgs.unstable.equibop;
      };
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.legcord.enable && cfg.vesktop.enable);
        message = "You must either enable Legcord or Vesktop, not both";
      }
      {
        assertion = !(cfg.openasar.enable && (cfg.legcord.enable || cfg.vesktop.enable));
        message = "OpenASAR has no effect on alternative clients";
      }
      {
        assertion = !(cfg.vencord.enable && (cfg.legcord.enable || cfg.vesktop.enable));
        message = "Vencord has no effect on alternative clients";
      }
    ];

    user.packages = [
      finalPackage
    ];
  };
}
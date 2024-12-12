{ lib, config, pkgs, system, inputs, ... }:

with lib;
let
  cfg = config.modules.software.system.audiorelay;
in {
  options.modules.software.system.audiorelay = {
    enable = mkEnableOption "Enable AudioRelay and its associated stack for using a phone as a microphone";
  };

  config = mkIf cfg.enable {
    modules.software.tools.noisetorch.enable = true;

    hm.home.packages = [
      inputs.stackpkgs.packages.${system}.audiorelay
    ];

    # https://discourse.nixos.org/t/using-a-phone-as-a-microphone/57172
    services.pipewire.extraConfig.pipewire."97-virtual-mic" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "audio.position" = "FL,FR";
            "node.description" = "AudioRelay sink";
            "capture.props" = {
              "node.name" = "capture.audiorelay";
              "node.description" = "AudioRelay sink (in)";
              "media.class" = "Audio/Sink";
              "node.passive" = true;
            };
            "playback.props" = {
              "node.name" = "playback.audiorelay";
              "node.description" = "AudioRelay sink (out)";
              "media.class" = "Audio/Source";
              "node.passive" = true;
            };
          };
        }
      ];
    };

    # audiorelay requires a few ports open for fetching devices
    networking.firewall.allowedTCPPorts = [
      59100 59200 59716
    ];
    networking.firewall.allowedUDPPorts = [
      59100 59200 59716
    ];
  };
}
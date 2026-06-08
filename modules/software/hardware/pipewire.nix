{ config, lib, ... }:

with lib;
let
  cfg = config.modules.hardware.pipewire;

  # the idea with these values is to strike an alright balance between performance
  # and quality. i'm the kind of faggot who likes both really good music quality
  # (and owns good audio hardware) and plays rhythm games.
  # normally you kind of sacrifice latency for quality with these but this is
  # an Okay middleground that's decent for a cpu like mine. hopefully
  defaultRate = 48000;
  # buffer size. lower size = less latency but less stability
  # default is what's used unless otherwise specified by the program
  defaultQuantum = 128;
  minQuantum = 64;
  maxQuantum = 256;
  # https://wiki.archlinux.org/title/PipeWire#Resampling
  resampleQuality = 10;
in {
  options.modules.hardware.pipewire = {
    enable = mkEnableOption "Enable pipewire, a modern audio server";
    # TODO make this an actual toggle again
    #lowLatency = mkEnableOption "Enable low latency configuration for audio production, rhythm games and similar";
  };

  config = mkIf cfg.enable {
    # Enable sound with pipewire.
    #sound.enable = true;
    services.pulseaudio.enable = false;

    security.rtkit.enable = true;
    boot.kernelParams = [ "threadirqs" ];
    user.extraGroups = [ "audio" "rtkit" ];

    # allow members of "audio" to set RT priorities up to 90
    security.pam.loginLimits = [{
      domain = "@audio";
      type = "-";
      item = "rtprio";
      value = "90";
    }];
    # expose important timers etc. to "audio"
    services.udev.extraRules = ''
      DEVPATH=="/devices/virtual/misc/cpu_dma_latency", OWNER="root", GROUP="audio", MODE="0660"
      DEVPATH=="/devices/virtual/misc/hpet", OWNER="root", GROUP="audio", MODE="0660"
    '';

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      #jack.enable = true;

      # referencing a couple of things here:
      # 1. https://nixos.wiki/wiki/PipeWire#Low-latency_setup for the initial quantum and rates setup
      # 2. https://wiki.archlinux.org/title/PipeWire for value meanings
      # 3. https://forum.endeavouros.com/t/hifi-sound-configuration-for-pipewire/65407 this thread is incohesive but there's some insight to be gathered
      # 4. https://github.com/fufexan/nix-gaming/blob/master/modules/pipewireLowLatency.nix a similar module to this
      extraConfig.pipewire."92-latency-rate-tweaks" = {
        "stream.properties" = {
          "node.latency" = "${toString defaultQuantum}/48000";
          "resample.quality" = resampleQuality;
        };
        "context.properties" = {
          "default.clock.rate" = defaultRate;

          # avoid resampling with this one simple trick
          # /proc/asound/card3/stream0:1:MOONDROP MOONDROP Dawn Pro at usb-0000:00:14.0-2.2, high speed : USB Audio
          # Rates: 44100, 48000, 88200, 96000, 176400, 192000, 352800, 384000

          "default.clock.allowed-rates" = [ 44100 48000 88200 96000 176400 192000 352800 384000 ];
          "default.clock.quantum" = defaultQuantum;
          "default.clock.min-quantum" = minQuantum;
          "default.clock.max-quantum" = maxQuantum;
        };

        "context.modules" = [
          {
            name = "libpipewire-module-rt";
            flags = [
              "ifexists"
              "nofail"
            ];
            args = {
              "nice.level" = -15;
              "rt.prio" = 88;
              "rt.time.soft" = 200000;
              "rt.time.hard" = 200000;
            };
          }
        ];
      };
      extraConfig.pipewire-pulse."92-latency-rate-tweaks" = {
        "stream.properties" = {
          "node.latency" = "${toString defaultQuantum}/48000";
          "resample.quality" = resampleQuality;
        };
        "pulse.properties" = {
          "pulse.min.req" = "${toString minQuantum}/48000";
          "pulse.min.quantum" = "${toString minQuantum}/48000";
          "pulse.min.frag" = "${toString minQuantum}/48000";
          "pulse.default.req" = "${toString defaultQuantum}/48000";
          "pulse.default.frag" = "${toString defaultQuantum}/48000";
          "pulse.max.req" = "${toString maxQuantum}/48000";
          "pulse.max.quantum" = "${toString maxQuantum}/48000";
        };
      };
      extraConfig.client."92-latency-rate-tweaks" = {
        "stream.properties" = {
          "node.latency" = "${toString defaultQuantum}/48000";
          "resample.quality" = resampleQuality;
        };
      };
      wireplumber.extraConfig."90-disable-suspend" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "~alsa_input.*"; }
              { "device.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "session.suspend-timeout-seconds" = 0;
              };
            };
          }
        ];
      };
      wireplumber.extraConfig."92-latency-rate-tweaks" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              { "device.name" = "~alsa_output.*"; }
            ];
            actions = {
              update-props = {
                "api.alsa.period-size" = 256;
                "api.alsa.period-num" = 3;
                "api.alsa.headroom" = 1024;
                "resample.quality" = resampleQuality;
                "resample.disable" = false;
                "channelmix.normalize" = false;
                "channelmix.mix-lfe" = false;
                "audio.channels" = 2;
                "audio.format" = "S24_LE";
                "audio.rate" = defaultRate;
                "audio.position" = "FL,FR";
              };
            };
          }
        ];
      };
    };
  };
}

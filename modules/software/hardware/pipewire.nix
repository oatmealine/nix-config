{ config, lib, ... }:

with lib;
let
  cfg = config.modules.hardware.pipewire;
in {
  options.modules.hardware.pipewire = {
    enable = mkEnableOption "Enable pipewire, a modern audio server";
  };

  config = mkIf cfg.enable {
    # Enable sound with pipewire.
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
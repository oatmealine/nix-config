{ lib, config, inputs, pkgs, ... }:

with lib;
let
  cfg = config.gnome;
in {
  options.gnome = {
    enable = mkEnableOption "Use GNOME as the desktop manager";
    wayland = mkEnableOption "Use Wayland";
  };

  config = mkIf cfg.enable {
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.desktopManager.gnome.enable = true;

    services.xserver.displayManager.gdm = {
      enable = true;
      wayland = mkForce cfg.wayland;
    };
  };
}

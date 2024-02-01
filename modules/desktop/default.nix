{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    envProto = mkOption {
      type = types.nullOr (types.enum ["x11" "wayland"]);
      description = "What display protocol to use.";
      default = null;
    };
  };

  config = mkMerge [
    {
      qt = {
        enable = true;
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      modules.desktop.fonts.enable = true;
      modules.desktop.fonts.baseFonts = true;

      #xdg.portal = {
      #  enable = true;
      #  extraPortals = [pkgs.xdg-desktop-portal-gtk];
      #  config.common.default = "*";
      #};

      services.gnome.gnome-keyring.enable = true;

      # Bootloader
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;

      # Enable networking
      networking.networkmanager.enable = true;

      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd.services.systemd-udev-settle.enable = false;
      systemd.services.NetworkManager-wait-online.enable = false;
    }
    (mkIf (cfg.envProto == "wayland") {
      # https://github.com/NixOS/nixpkgs/commit/b2eb5f62a7fd94ab58acafec9f64e54f97c508a6
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    })
    (mkIf (cfg.envProto == "x11") {
      services.xserver.excludePackages = [ pkgs.xterm ];
    })
  ];
}
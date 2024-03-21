{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.sddm;
in {
  options.modules.desktop.sddm = {
    enable = mkEnableOption "Enable SDDM, a display manager for X11 and Wayland windowing systems";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true; # oouhhuuhuuhuuuruuhuhuhu
    environment.systemPackages = with pkgs; [
      config.modules.desktop.themes.sddmTheme.package
      libsForQt5.qt5.qtsvg
      libsForQt5.qt5.qtgraphicaleffects
      libsForQt5.qt5.qtquickcontrols2
    ];
    services.xserver.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = config.modules.desktop.themes.sddmTheme.name;
      settings = {
        Theme = {
          CursorTheme = config.modules.desktop.themes.cursor.name;
        };
      };
    };
  };
}
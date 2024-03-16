{ lib, config, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.desktop.nwg-drawer;
in {
  options.modules.desktop.nwg-drawer = {
    enable = mkEnableOption "Enable nwg-drawer, a GTK-based application launcher for Wayland";
  };

  config = mkIf cfg.enable {
    hm.wayland.windowManager.hyprland.settings.exec-once = [ "${lib.getExe pkgs.nwg-drawer} -r -nofs -nocats -term wezterm -spacing 15 -fm nautilus" ];
    hm.xdg.configFile."nwg-drawer/drawer.css".text =
      builtins.concatStringsSep "\n" [
        "@import \"${inputs.waybar-catppuccin}/themes/mocha.css\";"
        (lib.readFile ../../config/nwg-drawer.css)
      ];
  };
}
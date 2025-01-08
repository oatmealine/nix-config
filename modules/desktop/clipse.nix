{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop.clipse;
in {
  options.modules.desktop.clipse = {
    enable = mkEnableOption "Enable clipse, a generic clipboard manager";
    package = mkOption {
      type = types.package;
      default = pkgs.clipse;
    };
  };

  config = mkIf cfg.enable {
    modules.desktop.execOnStart = [
      "${lib.getExe cfg.package} --listen-shell"
    ];
    hm.wayland.windowManager.hyprland.settings = let
      class = "clipse";
    in {
      windowrulev2 = [
        "float, class:^${class}$"
        "size 622 652, class:^${class}$"
        "stayfocused, class:^${class}$"
        "dimaround, class:^${class}$"
      ];

      #bind = [
      #  "$mod, V, exec, ${lib.getExe pkgs.wezterm} start --class ${class} -e '${lib.getExe cfg.package}'"
      #];
    };
  };
}
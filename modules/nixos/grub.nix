{ lib, config, pkga, ... }:

with lib;
let
  cfg = config.grubConfig;
in {
  options.grubConfig = {
    enable = mkEnableOption "GRUB customization";
    font = mkOption {
      type = types.str;
    };
    fontSize = mkOption {
      type = types.number;
    };
  };

  config = mkIf cfg.enable {
    boot.loader.grub.enable = true;
    boot.loader.grub.font = cfg.font;
    boot.loader.grub.fontSize = cfg.fontSize;
  };
}
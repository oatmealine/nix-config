{ lib, config, ... }:

with lib;
let
  cfg = config.modules.software.distractions.steam;
in {
  options.modules.software.distractions.steam = {
    enable = mkEnableOption "Enable Steam, the game distribution software";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    # https://github.com/FeralInteractive/gamemode
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {};
    };
  };
}
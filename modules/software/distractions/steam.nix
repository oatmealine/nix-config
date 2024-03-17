{ lib, config, pkgs, ... }:

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
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    programs.steam.gamescopeSession = {
      enable = true;
	    args = [ "-W 1600" "-H 900" "-r 60" "--expose-wayland" "-e" ];
    };
    user.packages = [ pkgs.protontricks pkgs.steam-run ];
  };
}
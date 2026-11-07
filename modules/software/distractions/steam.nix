{ lib, config, pkgs, inputs, system, ... }:

with lib;
let
  cfg = config.modules.software.distractions.steam;
in {
  options.modules.software.distractions.steam = {
    enable = mkEnableOption "Enable Steam, the game distribution software";
    gamemode = mkEnableOption "Use gamemode, an on-demand Linux system performance optimizer";
    gamescope = mkEnableOption "Use gamescope, a mini-compositor for game performance";
    millennium = mkEnableOption "Use Millennium, a Steam clientmod";
    mangohud = mkEnableOption "Add MangoHUD to the Steam environment";
  };

  config = mkIf cfg.enable {
    programs.steam = let
      steam = if !cfg.millennium
        then pkgs.steam
        else inputs.millennium.legacyPackages.${system}.steamWithMillennium;
    in {
      enable = true;
      package = steam.override {
        extraLibraries = pkgs: [ pkgs.libxcb ];
        extraPkgs = (pkgs:
          (optional cfg.gamescope pkgs.gamescope) ++
          (optional cfg.mangohud pkgs.mangohud) ++
          (with pkgs; [
            libxcursor
            libxi
            libxinerama
            libxscrnsaver
            libpng
            libpulseaudio
            libvorbis
            stdenv.cc.cc.lib
            libkrb5
            keyutils
          ])
        );
      };
      extraCompatPackages = with pkgs; [
        (proton-ge-bin.overrideAttrs { steamDisplayName = proton-ge-bin.version; })
        my.proton-cachyos
        my.proton-lina-unity-leak-fix
      ];
      protontricks.enable = true;
    };
    # https://github.com/FeralInteractive/gamemode
    programs.gamemode = mkIf cfg.gamemode {
      enable = true;
      enableRenice = true;
      settings = {};
    };
    programs.gamescope = {
      enable = true;
      #capSysNice = true; # breaks with steam https://github.com/NixOS/nixpkgs/issues/351516
      env = {
        WLR_RENDERER = "vulkan";
        #DXVK_HDR = "1";
        ENABLE_GAMESCOPE_WSI = "1";
        #WINE_FULLSCREEN_FSR = "1";
        # Games allegedly prefer X11
        #SDL_VIDEODRIVER = "x11";
      };
    };
    user.packages = with pkgs; [ protontricks steam-run ];
  };
}

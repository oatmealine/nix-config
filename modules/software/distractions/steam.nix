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
  };

  config = mkIf cfg.enable {
    programs.steam = let
      steam = if !cfg.millennium
        then pkgs.unstable.steam
        else inputs.millennium.packages.${system}.default;
    in {
      enable = true;
      package = steam.override {
        extraPkgs = (pkgs: (optional cfg.gamescope pkgs.gamescope) ++ (with pkgs; [
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          libkrb5
          keyutils
        ]));
      };
      extraCompatPackages = with pkgs.unstable; [
        (proton-ge-bin.override { steamDisplayName = proton-ge-bin.version; })
        pkgs.my.proton-cachyos
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
        SDL_VIDEODRIVER = "x11";
      };
      args = [
        "--expose-wayland"

        "-e" # Enable steam integration
        "--steam"

        "--adaptive-sync"
        #"--hdr-enabled"
        #"--hdr-itm-enable"

        "--output-width 1920"
        "--output-height 1080"
        "-r 75"
      ];
    };
    user.packages = with pkgs; [ protontricks steam-run ];
  };
}

{ lib, config, pkgs, ... }:

with lib;
let
  # ty https://github.com/Misterio77/nix-config/blob/main/modules/home-manager/fonts.nix
  mkFontOption = kind: default: {
    family = mkOption {
      type = types.str;
      default = default.family;
      description = "Family name for ${kind} font profile";
      example = "Fira Code";
    };
    package = mkOption {
      type = types.package;
      default = default.package;
      description = "Package for ${kind} font profile";
      example = "pkgs.fira-code";
    };
    size = mkOption {
      type = types.number;
      default = default.size;
      description = "${kind} font profile size, px";
      example = "11";
    };
  };
  cfg = config.modules.desktop.fonts;
in {
  options.modules.desktop.fonts = {
    enable = mkEnableOption "Enable the font configuration module";
    baseFonts = mkEnableOption "Add a set of extra base fonts";
        
    fonts = {
      sans = mkFontOption "sans" {
        package = pkgs.atkinson-hyperlegible;
        family = "Atkinson Hyperlegible";
        size = 11;
      };
      sansSerif = mkFontOption "sans-serif" {
        package = pkgs.atkinson-hyperlegible;
        family = "Atkinson Hyperlegible";
        size = 11;
      };
      monospace = mkFontOption "monospace" {
        package = pkgs.cozette;
        family = "CozetteVector";
        size = 10;
      };
      monospaceBitmap = mkFontOption "bitmap monospace" {
        package = pkgs.cozette;
        family = "Cozette";
        size = 10;
      };
      emoji = mkFontOption "emoji" {
        package = pkgs.twitter-color-emoji;
        family = "Twitter Color Emoji";
        size = 10; # not applicable, but whatever
      };
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      fontconfig.enable = true;
      fontconfig.defaultFonts = {
        sans = [ cfg.fonts.sans.family ];
        sansSerif = [ cfg.fonts.sansSerif.family ];
        monospace = [ cfg.fonts.monospace.family ];
        emoji = [ cfg.fonts.emoji.family ];
      };
      enableGhostscriptFonts = true;
      packages = with pkgs; [  	
        corefonts
        noto-fonts
        noto-fonts-cjk-sans
        liberation_ttf
      ] ++ [
        cfg.fonts.sans.package
        cfg.fonts.sansSerif.package
        cfg.fonts.monospace.package
        cfg.fonts.monospaceBitmap.package
        cfg.fonts.emoji.package
      ];
    };

    hm.gtk.enable = true;
    hm.gtk.font = {
      inherit (cfg.fonts.sans) package name size;
    };
  } // (mkIf cfg.baseFonts {
    fonts.packages = with pkgs; [
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      atkinson-hyperlegible
      cozette
    ];
  });
}
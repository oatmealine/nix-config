# Opinionated tweaks and values. Mostly configurable!

{ lib, config, inputs, ... }:

with lib;
let
  # ty https://github.com/Misterio77/nix-config/blob/main/modules/home-manager/fonts.nix
  mkFontOption = kind: {
    family = mkOption {
      type = types.str;
      default = null;
      description = "Family name for ${kind} font profile";
      example = "Fira Code";
    };
    package = mkOption {
      type = types.package;
      default = null;
      description = "Package for ${kind} font profile";
      example = "pkgs.fira-code";
    };
    size = mkOption {
      type = types.number;
      default = 11;
      description = "${kind} font profile size, px";
      example = "11";
    };
  };
  cfg = config.opinions;
in {
  options.opinions = {
    enable = mkEnableOption "Whether to enable opinionated tweaks";
    
    fonts = mkOption {
      type = types.submodule {
        options = {
          regular = mkFontOption "regular";
          monospace = mkFontOption "monospace";
          monospaceBitmap = mkFontOption "bitmap monospace";
        };
      };
    };

    lowercaseXdgDirs = mkEnableOption "Make XDG folder names all lowercase";
  };

  config = mkIf cfg.enable {
    # fonts
    fonts.fontconfig.enable = true;
    home.packages = [ cfg.fonts.monospace.package cfg.regular.package ];

    # xdg dirs
    xdg.userDirs = mkIf cfg.lowercaseXdgDirs {
      enable = true;
      createDirectories = true;

      desktop = "$HOME/desktop";
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      music = "$HOME/music";
      pictures = "$HOME/pictures";
      publicShare = "$HOME/public";
      templates = "$HOME/templates";
      videos = "$HOME/videos";
    };
  };
}
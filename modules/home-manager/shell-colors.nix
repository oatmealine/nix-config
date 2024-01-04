# Sets up shell colors

{ lib, config, inputs, pkgs, ... }:

with lib;
let
  cfg = config.shellColors;
  nix-colors-lib = inputs.nix-colors.lib.contrib { inherit pkgs; };
in {
  options.shellColors = {
    enable = mkEnableOption "Enable shell color config";
  };

  config = mkIf cfg.enable {
    programs.fish = let
      colorScript = nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; };
    in {
      interactiveShellInit = ''
        sh ${colorScript}
      '';
    };
  };
}
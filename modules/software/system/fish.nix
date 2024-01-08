{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.software.system.fish;
  nix-colors-lib = inputs.nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.software.system.fish = {
    enable = mkEnableOption "Enable fish, the friendly interpreted shell";
  };

  config = mkIf cfg.enable {
    user.packages = [ pkgs.grc ];

    users.defaultUserShell = pkgs.fish;
    programs.fish.enable = true;
    hm.programs.fish = let
      colorScript = nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; };
    in {
      enable = true;
      plugins = [ { name = "grc"; src = pkgs.fishPlugins.grc.src; } ];
      interactiveShellInit = ''
        sh ${colorScript}
      '';
    };
  };
}
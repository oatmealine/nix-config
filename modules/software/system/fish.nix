{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.software.system.fish;
  nix-colors-lib = inputs.nix-colors.lib.contrib { inherit pkgs; };
in {
  options.modules.software.system.fish = {
    enable = mkEnableOption "Enable fish, the friendly interpreted shell";
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.fish;
    };
  };

  config = mkIf cfg.enable {
    user.packages = [ pkgs.grc ];

    environment.systemPackages = with pkgs.fishPlugins; [ fzf-fish tide done ];

    users.defaultUserShell = cfg.package;
    programs.fish.enable = true;
    programs.fish.package = cfg.package;
    hm.programs.fish = let
      colorScript = nix-colors-lib.shellThemeFromScheme { scheme = config.colorScheme; };
    in {
      enable = true;
      package = cfg.package;
      plugins = [ { name = "grc"; src = pkgs.fishPlugins.grc.src; } ];
      interactiveShellInit = ''
        sh ${colorScript}
      '';
      functions.fish_greeting = ''
        ${lib.getExe pkgs.fortune} -e ${pkgs.my.scold-fortunes}/share/fortune
      '';
    };
  };
}
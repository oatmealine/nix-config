{ config, lib, pkgs, inputs, ... }:

with lib;
let
  cfg = config.modules.software.dev.direnv;
in {
  options.modules.software.dev.direnv = {
    enable = mkEnableOption "Enable direnv, the environment switcher";
  };

  config = mkIf cfg.enable {
    hm.programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}

{ lib, config, ... }:
with lib;
let
  cfg = config.modules.dev;
in {
  options.modules.dev = {
    enable = mkEnableOption "general dev utilities";
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      silent = true;
      nix-direnv.enable = true;
    };
  };
}
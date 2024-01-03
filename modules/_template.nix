# Module template

{ lib, config, inputs, ... }:

with lib;
let
  cfg = config.thing;
in {
  options.thing = {
    enable = mkEnableOption "TODO";
  };

  config = mkIf cfg.enable {

  };
}
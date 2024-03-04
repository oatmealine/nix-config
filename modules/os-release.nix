{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.os-release;
in {
  options.modules.os-release = {
    enable = mkEnableOption "Modify /etc/os-release. Highly cursed";
    logo = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    environment.etc."os-release" = let
      orig = config.environment.etc."os-release".text; # help
      replaced = replaceStrings [ "nix-snowflake" ] [ cfg.logo ] orig;
    in {
      source = mkForce (pkgs.writeText "os-release" replaced);
    };
  };
}
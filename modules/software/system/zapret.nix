# i hate this godforsaken country

{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.zapret;
in {
  options.modules.software.system.zapret = {
    enable = mkEnableOption "Enable zapret, a DPI bypass service";
    params = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "nfqws parameters. These will depend per network device; run `blockcheck` to get a possible list of working parameters.";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.unstable.zapret;
      example = "pkgs.zapret";
    };
  };

  config = mkIf cfg.enable {
    hm.home.packages = [ cfg.package ];

    services.zapret = {
      enable = true;
      package = cfg.package;
      params = cfg.params;
    };

    systemd.services.zapret = {
      wantedBy = lib.mkForce [];
    };
  };
}
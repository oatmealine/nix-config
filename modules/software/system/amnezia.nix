# this is mostly a placeholder module until the client's fully working;
# for now just use awg-quick

{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.amnezia;
in {
  options.modules.software.system.amnezia = {
    enable = mkEnableOption "Enable AmneziaVPN, a free and open-source personal VPN client and server";
  };

  config = mkIf cfg.enable {
    hm.home.packages = with pkgs; [
      unstable.amneziawg-tools
      my.amnezia-client
    ];

    boot.extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];
  };
}
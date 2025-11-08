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
      amneziawg-tools
      amnezia-vpn
    ];

    programs.amnezia-vpn = {
      enable = true;
      package = pkgs.amnezia-vpn;
    };

    boot.extraModulePackages = with config.boot.kernelPackages; [
      amneziawg
    ];

    /*hm.programs.waybar.settings.mainBar."custom/vpn" = let
      interface = "wg0";
      awg = "${pkgs.unstable.amneziawg-tools}/bin/awg";
      awg-quick = "${pkgs.unstable.amneziawg-tools}/bin/awg-quick";
      script = pkgs.writeScript "awg-ctl" ''
        set -euo pipefail

        status=$(sudo ${awg} show | grep -q '${interface}' && echo "up" || echo "down")

        case "''${1:-}" in
          show)
            echo "{\"text\": \"󰌆\", \"tooltip\": \"${interface}: $status\", \"class\": \"$status\"}"
            ;;
          toggle)
            if [ "$status" = "up" ]; then
              sudo ${awg-quick} down ${interface}
              status="down"
              bool="false"
            else
              sudo ${awg-quick} up ${interface}
              status="up"
              bool="true"
            fi
            notify-send \
              "${interface}" \
              "$status" \
              -i "network-vpn-symbolic"
            ;;
        esac
      '';
    in {
      format = "{}";
      tooltip = true;
      interval = 1;
      exec = "${script} show";
      on-click = "${script} toggle";
      return-type = "json";
    };*/
  };
}

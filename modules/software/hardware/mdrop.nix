{ config, lib, inputs, pkgs, system, ... }:

with lib;
let
  cfg = config.modules.hardware.mdrop;
in {
  options.modules.hardware.mdrop = {
    enable = mkEnableOption "Enable mdrop, a tool for controlling Moondrop USB DACs";
    package = mkOption {
      type = types.package;
      default = inputs.mdrop.packages.${system}.gui;
    };
  };

  config = mkIf cfg.enable {
    hm.home.packages = [ cfg.package ];
    services.udev.extraRules = ''SUBSYSTEM=="usb", ATTRS{idVendor}=="2fc6", MODE="0666"'';

    hm.programs.waybar.settings.mainBar."custom/mdrop" = let
      mdrop = "${cfg.package}/bin/mdrop";
      script = pkgs.writeScript "mdrop-cli" ''
        set -euo pipefail

        # waste a few calls bc that somehow unbreaks it
        temp1=$(${mdrop} get volume)
        temp2=$(${mdrop} get volume)
        temp3=$(${mdrop} get volume)
        temp4=$(${mdrop} get volume)
        temp5=$(${mdrop} get volume)
        temp6=$(${mdrop} get volume)
        temp7=$(${mdrop} get volume)

        volume=$(${mdrop} get volume | sed 's/[^0-9]//g')
        filter=$(${mdrop} get filter | sed 's/Filter: //g')
        gain=$(${mdrop} get gain | sed 's/Gain: //g')

        case "''${1:-}" in
          show)
            class="default"
            if (( volume == 0 )); then
              class="muted"
            fi
            
            echo "{\"percentage\": $volume, \"tooltip\": \"Gain: $gain, filter: $filter\", \"class\": \"$class\", \"alt\": \"$class\"}"
            ;;
          up)
            ${mdrop} set volume $(($volume+1))
            ;;
          down)
            ${mdrop} set volume $(($volume-1))
            ;;
        esac
      '';
    in {
      format = "{icon} {percentage}%";
      format-icons = {
        muted = "婢";
        default = ["" "" ""];
      };
      tooltip = true;
      interval = 2;
      exec = "${script} show";
      on-click = "${lib.getExe pkgs.pavucontrol}";
      on-scroll-up = "${script} up";
      on-scroll-down = "${script} down";
      return-type = "json";
    };
  };
}
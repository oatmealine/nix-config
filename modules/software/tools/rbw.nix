{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.tools.rbw;
in {
  options.modules.software.tools.rbw = {
    enable = mkEnableOption "Enable rbw, a Bitwarden CLI password manager";
  };

  config = mkIf cfg.enable {
    hm.programs.rbw = let
      passwordPath = "/home/oatmealine/sync/secrets/bitwardenpass-raw";
      # thank you, random site i found with google
      # https://fossies.org/linux/gnupg/tests/fake-pinentries/fake-pinentry.sh
      getPassword = pkgs.writeShellScriptBin "get-bw-password" ''
        echo "OK ready"
        while read cmd rest; do
          cmd=$(printf "%s" "$cmd" | tr 'A-Z' 'a-z')
          if [ -z "$cmd" ]; then
            continue;
          fi
          case "$cmd" in
            \#*)
            ;;
            getpin)
              echo "D $(cat ${passwordPath})"
              echo "OK"
              ;;
            bye)
              echo "OK"
              exit 0
              ;;
            *)
              echo "OK"
              ;;
          esac
        done
      '';
    in {
      enable = true;
      settings.base_url = "https://bitwarden.lavatech.top";
      settings.email = "oatmealine@disroot.org";
      settings.lock_timeout = 60 * 60 * 24 * 7; # 1 week
      settings.pinentry = getPassword.overrideAttrs (old: { binaryPath = "bin/get-bw-password"; });
    };
  };
}
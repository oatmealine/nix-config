{ config, lib, ... }:

with lib;
let
  cfg = config.modules.ssh;
in {
  options.modules.ssh = {
    enable = mkEnableOption "Enable ssh. You know what ssh is";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
        UseDns = true;
        X11Forwarding = false;
        PermitRootLogin = "prohibit-password"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };
    networking.firewall.allowedTCPPorts = [ 22 ];
  };
}
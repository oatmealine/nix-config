{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.security;
in {
  options.modules.security = {
    useDoas = mkEnableOption "Use opendoas instead of sudo";
  };

  config = {
    boot = {
      tmp.useTmpfs = lib.mkDefault true;
      tmp.cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);

      # Disable kernel-param editing on boot
      loader.systemd-boot.editor = false;

      kernel.sysctl = {
        # Magic SysRq key -> allows performing low-level commands.
        "kernel.sysrq" = 0;

        ## TCP hardening
        # Prevent bogus ICMP errors from filling up logs.
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        # Reverse path filtering causes the kernel to do source validation of
        # packets received from all interfaces. This can mitigate IP spoofing.
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.rp_filter" = 1;
        # Do not accept IP source route packets (we're not a router)
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        # Don't send ICMP redirects (again, we're on a router)
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        # Refuse ICMP redirects (MITM mitigations)
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.all.secure_redirects" = 0;
        "net.ipv4.conf.default.secure_redirects" = 0;
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        # Protects against SYN flood attacks
        "net.ipv4.tcp_syncookies" = 1;
        # Incomplete protection again TIME-WAIT assassination
        "net.ipv4.tcp_rfc1337" = 1;

        ## TCP optimization
        # Enable TCP Fast Open for incoming and outgoing connections
        "net.ipv4.tcp_fastopen" = 3;
        # Bufferbloat mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
      };
      kernelModules = ["tcp_bbr"];
    };

    user.initialPassword = "nixos";
    users.users.root.initialPassword = "nixos";

    security = {
      # Prevent replacing the running kernel w/o reboot
      protectKernelImage = true;
      # Allows unautherized applications -> send unautherization request
      polkit.enable = true;
      rtkit.enable = true;
    };

    networking.firewall.enable = false;

    services.usbguard = {
      IPCAllowedUsers = [ "root" "${env.mainUser}" ];
      presentDevicePolicy = "allow";
      rules = ''
        allow with-interface equals { 08:*:* }

        # Reject devices with suspicious combination of interfaces
        reject with-interface all-of { 08:*:* 03:00:* }
        reject with-interface all-of { 08:*:* 03:01:* }
        reject with-interface all-of { 08:*:* e0:*:* }
        reject with-interface all-of { 08:*:* 02:*:* }
      '';
    };

    environment.systemPackages = [ pkgs.usbguard ];
  } // (mkIf cfg.useDoas {
    security.sudo.enable = false;
    security.doas.enable = true;
    security.doas.extraRules = [
      { users = [ config.user.name ]; noPass = true; persist = false; keepEnv = true; }
    ];
    environment.systemPackages = with pkgs; [ doas-sudo-shim ];
  });
}

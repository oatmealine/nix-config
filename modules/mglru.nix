{pkgs, ...}:
{
  systemd.services."config-mglru" = {
    enable = true;
    after = ["basic.target"];
    wantedBy = ["sysinit.target"];
    script = ''
      ${pkgs.coreutils}/bin/echo Y > /sys/kernel/mm/lru_gen/enabled
      ${pkgs.coreutils}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms
    '';
  };
}
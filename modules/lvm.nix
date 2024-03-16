{lib, ...}:
{
  # I don't use lvm, can be disabled
  services.lvm.enable = lib.mkDefault false;
}
{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.software.system.virt-manager;
in {
  options.modules.software.system.virt-manager = {
    enable = mkEnableOption "Enable virt-manager, a GUI VM manager and runner";
  };

  config = mkIf cfg.enable {
    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ config.user.name ];

    virtualisation.libvirtd.enable = true;
    virtualisation.libvirtd.qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    virtualisation.spiceUSBRedirection.enable = true;

    hm.dconf.settings = {
      "org/virt-manager/virt-manager/connections" = {
        autoconnect = ["qemu:///system"];
        uris = ["qemu:///system"];
      };
    };
  };
}
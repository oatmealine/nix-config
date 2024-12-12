{ inputs, config, lib, modulesPath, pkgs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wwp0s20u4i6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" "amdgpu" ];
  boot.extraModulePackages = [ ];

  hardware.graphics.enable32Bit = true;
  hardware.graphics.extraPackages = with pkgs; [
    amdvlk
  ];
  # For 32 bit applications 
  hardware.graphics.extraPackages32 = with pkgs; [
    driversi686Linux.amdvlk
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  systemd.tmpfiles.rules = [
    "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
  ];

  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/aa177751-fcc0-4a16-9902-11f75a73172c";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d893f835-0dcd-47a6-97b1-25bbf0203164";
      fsType = "ext4";
    };

  swapDevices = [ ];
  # this isn't actually necessary as systemd will auto-detect swap partitions
  #swapDevices =
  #  [ { device = "/dev/disk/by-uuid/d5b2d890-dbbf-4ab9-90cc-944bc3538b56"; }
  #  ];
}

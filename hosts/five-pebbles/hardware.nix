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
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';

  hardware.amdgpu.initrd.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  # amdvlk is deprecated and ass and bad and etc. byebye
  #hardware.graphics.extraPackages = with pkgs; [
  #  amdvlk
  #];
  # For 32 bit applications 
  #hardware.graphics.extraPackages32 = with pkgs; [
  #  driversi686Linux.amdvlk
  #];

  # always prefer radv over amdvlk
  environment.variables.AMD_VULKAN_ICD = "RADV";

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
      options = [ "noatime" "nodiratime" "discard" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/d893f835-0dcd-47a6-97b1-25bbf0203164";
      fsType = "ext4";
    };
  fileSystems."/run/media/oatmealine/8014a2d1-7458-4ad8-a9bc-fa018042a411" =
    { device = "/dev/disk/by-uuid/8014a2d1-7458-4ad8-a9bc-fa018042a411";
      fsType = "ext4";
      options = [ "noatime" "nodiratime" "discard" ];
    };

  swapDevices = [ ];
  # this isn't actually necessary as systemd will auto-detect swap partitions
  #swapDevices =
  #  [ { device = "/dev/disk/by-uuid/d5b2d890-dbbf-4ab9-90cc-944bc3538b56"; }
  #  ];

  # fix suspend not working
  services.udev.extraRules = lib.concatStringsSep ", " [
    ''ACTION=="add"''

    ''SUBSYSTEM=="pci"''
    ''ATTR{vendor}=="0x8086"'' 
    ''ATTR{device}=="0x43ed"''

    ''ATTR{power/wakeup}="disabled"''
  ];
}

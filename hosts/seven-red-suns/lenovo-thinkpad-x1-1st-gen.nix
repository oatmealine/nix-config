# Largely based upon https://www.thinkwiki.org/wiki/X1_Linux_Tweaks

{ pkgs, ... }:
{
  # Laptop-specific battery usage tuning
  powerManagement.enable = true;
  # Tune power saving options on boot
  powerManagement.powertop.enable = true;
  # Thermald proactively prevents overheating on Intel CPUs and works well with other tools.
  services.thermald.enable = true;
  # Use power-profile-daemon for battery saving management
  services.power-profiles-daemon.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  services.blueman.enable = true;

  # better performance than the actual Intel driver
  services.xserver.videoDrivers = ["modesetting"];

  # OpenCL support and VAAPI
  hardware.opengl = {
    extraPackages = with pkgs; [
      #intel-compute-runtime
      intel-media-driver
      libvdpau-va-gl
    ];

    extraPackages32 = with pkgs.pkgsi686Linux; [
      #intel-compute-runtime
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.variables = {
    LIBVA_DRIVER_NAME = "iHD";
    VDPAU_DRIVER = "va_gl";
  };

  environment.systemPackages = with pkgs; [ intel-gpu-tools ];

  boot.kernelParams = [
    # Enable the i915 Sandybridge Framebuffer Compression (confirmed 475mw savings)
    "i915.i915_enable_fbc=1"
    "i915.fastboot=1"
    "enable_gvt=1"
  ];
}
# Largely based upon https://www.thinkwiki.org/wiki/X1_Linux_Tweaks

{ ... }:
{
  # Laptop-specific battery usage tuning
  powerManagement.enable = true;
  # Tune power saving options on boot
  powerManagement.powertop.enable = true;
  # Thermald proactively prevents overheating on Intel CPUs and works well with other tools.
  services.thermald.enable = true;
  # Use power-profile-daemon for battery saving management
  services.power-profiles-daemon.enable = true;

  boot.kernelParams = [
    # Enable the i915 Sandybridge Framebuffer Compression (confirmed 475mw savings)
    "i915.i915_enable_fbc=1"
  ];
}
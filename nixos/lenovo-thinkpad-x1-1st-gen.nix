# Largely based upon https://www.thinkwiki.org/wiki/X1_Linux_Tweaks

{ config, ... }:
{
  # Laptop-specific battery usage tuning
  #powerManagement.powertop.enable = true;
  boot.kernelParams = [
    # Enable the i915 Sandybridge Framebuffer Compression (confirmed 475mw savings)
    "i915.i915_enable_fbc=1"
  ];
}
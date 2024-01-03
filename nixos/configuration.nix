{ config, pkgs, inputs, outputs, ... }:

{
  imports =
    [
      inputs.hardware.nixosModules.common-cpu-intel
      inputs.hardware.nixosModules.common-pc-laptop-ssd
      inputs.hardware.nixosModules.common-pc-laptop
      ./lenovo-thinkpad-x1-1st-gen.nix

      ./hardware-configuration.nix

      outputs.nixosModules.grub
      outputs.nixosModules.gnome

      ./security.nix
      ./users.nix
      ./software.nix
    ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowAliases = false;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #grubConfig = {
  #  enable = true;
  #  font = "${pkgs.cozette}/share/fonts/truetype/CozetteVector.ttf";
  #  fontSize = 10;
  #};

  networking.hostName = "goop-drive"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "workman";
  };
  console.useXkbConfig = true;

  # Enable CUPS to print documents.
  #services.printing.enable = false;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}

{ pkgs, inputs, ... }:

{
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  gnome = {
    enable = true;
    wayland = false;
  };

  programs.fish.enable = true;
  users.defaultUserShell = pkgs.fish;
  programs.steam.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	micro
  	git
  	curl
  	wget
    doas
    catppuccin-gtk
    home-manager
  ];

  environment.variables.EDITOR = "micro";

  fonts.packages = with pkgs; [  	
    corefonts
    noto-fonts
    noto-fonts-cjk-sans
    twitter-color-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
    atkinson-hyperlegible
    cozette
  ];
}

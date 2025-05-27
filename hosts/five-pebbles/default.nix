{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    ./hardware.nix
  ];

  hm.home.packages = with pkgs; [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq libqalculate ffmpeg imagemagick binutils
    # nix
    nix-output-monitor
    # dev
    sqlitebrowser sqlite-interactive nil
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall ipset gparted seahorse
    # debug
    strace ltrace lsof helvum
    # apps
    vivaldi telegram-desktop onlyoffice-desktopeditors mpv qalculate-gtk krita inkscape obsidian vlc kdePackages.kdenlive audacity aseprite imhex
    # compatilibility
    unstable.wineWowPackages.unstableFull winetricks
    # misc
    cowsay file which tree gnused yt-dlp libnotify font-manager wev tauon soulseekqt transmission_4-gtk
    # love2d (to be moved elsewhere)
    love my.love-release
    #my.love-js
    # games
    unstable.ringracers unstable.prismlauncher unstable.r2modman my.ryujinx my.olympus

    # https://gist.github.com/Lgmrszd/98fb7054e63a7199f9510ba20a39bc67
    (symlinkJoin {
      name = "idea-community";
      paths = [ jetbrains.idea-community ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/idea-community \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libpulseaudio libGL glfw openal stdenv.cc.cc.lib xorg.libX11 xorg.libXcursor]}"
      '';
    })
  ] ++ (with pkgs.my; [
    iterator-icons mxlrc-go sdfgen
  ]) ++ (with pkgs.gnome; [
    # these are usually defaults, but are missing when non-gnome DEs are used
    # however gnome apps are my beloved so i'm just adding them back
    nautilus gnome-system-monitor pkgs.loupe gnome-disk-utility pkgs.gedit file-roller
  ]);

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_stable;

  fileSystems."/home/oatmealine/downloads" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=2G" "mode=777" ];
  };

  # work around a really annoying systemd issue
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
  systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";

  hm.programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-capture
      input-overlay
    ];
  };

  modules = {
    #ssh.enable = true;

    security.useDoas = true;
    os-release = {
      enable = true;
      logo = "color-five-pebbles";
    };

    hardware = {
      pipewire.enable = true;
      # seems a little Freaky right now
      #pipewire.lowLatency = true;
    };
    dev = {
      enable = true;
      #crystal.enable = true;
    };
    desktop = {
      envProto = "wayland";

      niri.enable = true;
      swww.enable = true;
      #hypridle.enable = true;
      #hypridle.desktop = true;

      mako.enable = true;
      mako.osd = true;
      waybar.enable = true;
      waybar.hostname = "five-pebbles";
      rofi.enable = true;
      cliphist.enable = true;
      #clipse.enable = true;
      fuzzel.enable = true;

      sddm.enable = true;
      sddm.autologin = true;

      themes.active = "catppuccin";
    };
    software = {
      # system
      system.amnezia.enable = true;
      system.audiorelay.enable = true;
      system.wezterm.enable = true;
      system.fish.enable = true;
      system.syncthing.enable = true;
      system.flatpak.enable = true;
      system.virt-manager.enable = true;
      # dev
      dev.git.enable = true;
      # editors
      editors.vscode.enable = true;
      editors.micro.enable = true;
      # tools
      tools.rbw.enable = true;
      tools.noisetorch.enable = true;
      # distractions
      distractions.steam.enable = true;
      distractions.steam.gamemode = true;
      distractions.steam.useGamescope = true;
      distractions.discord.enable = true;
      #distractions.discord.vesktop = true;
      #distractions.discord.openasar = true;
    };
  };
}

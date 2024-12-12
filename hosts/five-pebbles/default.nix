{ pkgs, lib, config, inputs, ... }:
{
  imports = [
    ./hardware.nix

    inputs.musnix.nixosModules.musnix
  ];

  hm.home.packages = with pkgs; [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq libqalculate
    # nix
    nix-output-monitor
    # dev
    sqlitebrowser sqlite-interactive nil
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall ipset
    # debug
    strace ltrace lsof helvum
    # apps
    vivaldi telegram-desktop onlyoffice-desktopeditors mpv qalculate-gtk krita inkscape obsidian vlc
    # compatilibility
    wine winetricks
    # misc
    cowsay file which tree gnused yt-dlp libnotify font-manager wev tauon
    # games
    unstable.ringracers prismlauncher
  ] ++ (with pkgs.my; [
    iterator-icons mxlrc-go sdfgen
  ]) ++ (with pkgs.gnome; [
    # these are usually defaults, but are missing when non-gnome DEs are used
    # however gnome apps are my beloved so i'm just adding them back
    nautilus gnome-system-monitor pkgs.loupe gnome-disk-utility pkgs.gedit file-roller
  ]);

  musnix.enable = true;
  musnix.rtcqs.enable = true;

  fileSystems."/home/oatmealine/downloads" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=2G" "mode=777" ];
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
      hypridle.enable = true;
      hypridle.desktop = true;

      mako.enable = true;
      mako.osd = true;
      waybar.enable = true;
      waybar.hostname = "five-pebbles";
      rofi.enable = true;
      clipse.enable = true;
      fuzzel.enable = true;

      sddm.enable = true;

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
      distractions.discord.enable = true;
      distractions.discord.vesktop = true;
    };
  };
}

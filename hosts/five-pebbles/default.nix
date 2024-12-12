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

  # usually you don't need to do this, but this is a workaround for https://github.com/flameshot-org/flameshot/issues/3328
  #hm.services.flameshot.enable = true;

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
      
      /*gnome.enable = true;
      gnome.keybinds.shell = {
        # disable defaults
        "screenshot" = [];
        "screenshot-window" = [];
        "show-screenshot-ui" = [];
      };
      gnome.keybinds.custom = {
        "take-screenshot" = {
          binding = "Print";
          command = let
            screenshotScript = pkgs.writeScript "screenshot" "XDG_SESSION_TYPE=wayland ${lib.getExe pkgs.flameshot} gui -c";
          in ''${screenshotScript}'';
        };
        "take-screen-recording" = {
          binding = "<Shift>Print";
          command = "${lib.getExe pkgs.peek}";
        };
        "grab-password" = let
          grabScript = pkgs.writeScript "grab-password" ''
            ${lib.getExe pkgs.rbw} get $(${lib.getExe pkgs.gnome.zenity} --entry --text="" --title="") | ${lib.getExe pkgs.xclip} -selection clipboard
          '';
        in {
          binding = "Launch1";
          command = ''${grabScript}'';
        };
      };*/

      #xfce.enable = true;

      # in my mind they're a lesbian polycule
      #hyprland.enable = true;
      niri.enable = true;
      #hyprlock.enable = true;
      #hyprpaper.enable = true;
      swww.enable = true;
      hypridle.enable = true;
      hypridle.desktop = true;

      dunst.enable = true;
      waybar.enable = true;
      waybar.hostname = "five-pebbles";
      rofi.enable = true;
      wob.enable = true;
      clipse.enable = true;
      #batsignal.enable = true;
      fuzzel.enable = true;

      sddm.enable = true;

      #gammastep.enable = true;

      themes.active = "catppuccin";
    };
    software = {
      # system
      #system.alacritty.enable = true;
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

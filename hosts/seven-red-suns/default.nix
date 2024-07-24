{ pkgs, lib, ... }:
{
  imports = [ ./hardware.nix ];

  hm.home.packages = with pkgs; [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq libqalculate
    # nix
    nix-output-monitor
    # dev
    sqlitebrowser sqlite-interactive
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall
    # debug
    strace ltrace lsof
    # apps
    vivaldi telegram-desktop onlyoffice-bin mpv qalculate-gtk krita inkscape obsidian
    # compatilibility
    wineWowPackages.waylandFull winetricks
    # misc
    cowsay file which tree gnused yt-dlp libnotify
    # games
    unstable.ringracers prismlauncher
  ] ++ (with pkgs.my; [
    olympus iterator-icons
  ]) ++ (with pkgs.gnome; [
    # these are usually defaults, but are missing when non-gnome DEs are used
    # however gnome apps are my beloved so i'm just adding them back
    nautilus gnome-system-monitor pkgs.loupe gnome-disk-utility pkgs.gedit file-roller
  ]);

  # usually you don't need to do this, but this is a workaround for https://github.com/flameshot-org/flameshot/issues/3328
  hm.services.flameshot.enable = true;

  modules = {
    #ssh.enable = true;

    security.useDoas = true;
    os-release = {
      enable = true;
      logo = "seven-red-suns";
    };

    hardware = {
      pipewire.enable = true;
    };
    dev = {
      enable = true;
      crystal.enable = true;
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
      hyprland.enable = true;
      hyprlock.enable = true;
      hyprpaper.enable = true;
      hypridle.enable = true;

      dunst.enable = true;
      waybar.enable = true;
      rofi.enable = true;
      nwg-drawer.enable = true;
      wob.enable = true;
      clipse.enable = true;
      batsignal.enable = true;

      sddm.enable = true;

      gammastep.enable = true;

      themes.active = "catppuccin";
    };
    software = {
      # system
      #system.alacritty.enable = true;
      system.wezterm.enable = true;
      system.fish.enable = true;
      system.syncthing.enable = true;
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
      distractions.discord.armcord = true;
    };
  };
}

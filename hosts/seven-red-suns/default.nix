{ pkgs, lib, ... }:
{
  imports = [ ./hardware.nix ];

  hm.home.packages = with pkgs; [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq
    # nix
    nix-output-monitor
    # dev
    sqlitebrowser sqlite-interactive
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall
    # debug
    strace ltrace lsof
    # apps
    vivaldi telegram-desktop onlyoffice-bin mpv
    # compatilibility
    wine
    # misc
    cowsay file which tree gnused yt-dlp
  ];

  # usually you don't need to do this, but this is a workaround for https://github.com/flameshot-org/flameshot/issues/3328
  hm.services.flameshot.enable = true;

  modules = {
    security.useDoas = true;

    hardware = {
      pipewire.enable = true;
    };
    desktop = {
      envProto = "wayland";
      gnome.enable = true;
      gnome.keybinds.shell = {
        # disable defaults
        "screenshot" = [];
        "screenshot-window" = [];
        "show-screenshot-ui" = [];
      };
      gnome.keybinds.custom = {
        "take-screenshot" = {
          binding = "Print";
          command = "${lib.getExe pkgs.flameshot} gui";
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
      };
      #xfce.enable = true;
      themes.active = "catppuccin";
    };
    software = {
      # system
      system.alacritty.enable = true;
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
    };
  };
}

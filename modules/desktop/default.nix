{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.modules.desktop;
in {
  options.modules.desktop = {
    envProto = mkOption {
      type = types.nullOr (types.enum ["x11" "wayland"]);
      description = "What display protocol to use.";
      default = null;
    };
    execOnStart = mkOption {
      type = types.listOf types.str;
      description = "Commands to call upon startup";
      default = null;
    };
  };

  config = mkMerge [
    {
      hm.qt = {
        enable = true;
        platformTheme.name = lib.mkDefault "gnome";
        style.name = lib.mkDefault "adwaita-dark";
      };

      modules.desktop.fonts.enable = true;
      modules.desktop.fonts.baseFonts = true;

      modules.desktop.thumbnailers.enable = true;

      #xdg.portal = {
      #  enable = true;
      #  extraPortals = [pkgs.xdg-desktop-portal-gtk];
      #  config.common.default = "*";
      #};

      services.gnome.gnome-keyring.enable = true;
      services.gnome.gcr-ssh-agent.enable = true;
      #programs.ssh.startAgent = true;

      # Enable networking
      networking.networkmanager.enable = true;

      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      #systemd.services.systemd-udev-settle.enable = false;
      systemd.services.NetworkManager-wait-online.enable = false;

      # https://wiki.archlinux.org/title/Systemd/Journal#Persistent_journals
      # limit systemd journal size
      # journals get big really fasti and on desktops they are not audited often
      # on servers, however, they are important for both security and stability
      # thus, persisting them as is remains a good idea
      services.journald.extraConfig = ''
        SystemMaxUse=100M
        RuntimeMaxUse=50M
        SystemMaxFileSize=50M
      '';

      # MTP support : https://nixos.wiki/wiki/MTP
      services.gvfs.enable = true;

      programs.adb.enable = true;
      user.extraGroups = [ "adbusers" ];

      environment.systemPackages = [ pkgs.brightnessctl ];
      # fix for permission issues
      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
      '';
    }
    (mkIf (cfg.envProto == "wayland") {
      environment.sessionVariables = {
        # https://github.com/NixOS/nixpkgs/commit/b2eb5f62a7fd94ab58acafec9f64e54f97c508a6
        NIXOS_OZONE_WL = "1";
        # the rest are borrowed from https://github.com/NotAShelf/nyx/blob/9fbba55f565c630469a971bc71e5957dc228703b/modules/core/common/system/os/display/wayland/environment.nix#L18
        _JAVA_AWT_WM_NONEREPARENTING = "1";
        GDK_BACKEND = "wayland";
        ANKI_WAYLAND = "1";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        SDL_VIDEODRIVER = "wayland";
        CLUTTER_BACKEND = "wayland";
      };
      #programs.xwayland.enable = true;
      # temporary fix for https://github.com/nix-community/home-manager/issues/2064
      hm.systemd.user.targets.tray = {
        Unit = {
          Description = "Home Manager System Tray";
          Requires = [ "graphical-session-pre.target" ];
        };
      };
    })
    (mkIf (cfg.envProto == "x11") {
      services.xserver.excludePackages = [ pkgs.xterm ];
    })
  ];
}

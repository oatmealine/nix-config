{ pkgs, lib, config, inputs, system, ... }:
let 
  bridgewebhook = (let
    discordWebhookPath = "/etc/bridge-webhook";
  in (pkgs.writeScriptBin "bridgewebhook" ''
    [ -f "${discordWebhookPath}" ] || exit 0
    discordWebhookURL=$(cat "${discordWebhookPath}")
    payload=$(${lib.getExe pkgs.jq} -cn --arg content "$1" '{"content":$content}')

    ${lib.getExe pkgs.curl} "$discordWebhookURL" \
      -X POST \
      -H 'content-type: application/json' \
      -d "$payload"
  ''));
in {
  imports = [
    ./hardware.nix
  ];

  hm.home.packages = with pkgs; [
    # archives
    zip xz unzip p7zip
    # utils
    ripgrep jq libqalculate ffmpeg imagemagick binutils alsa-utils sox wl-clipboard
    # nix
    nix-output-monitor nh
    # dev
    sqlitebrowser sqlite-interactive nil dig python3 openssl assetripper
    patdiff glslang my.sdfgen
    # https://gist.github.com/Lgmrszd/98fb7054e63a7199f9510ba20a39bc67
    (symlinkJoin {
      name = "idea-oss";
      paths = [ jetbrains.idea-oss ];
      buildInputs = [ makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/idea-oss \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [libpulseaudio libGL glfw openal stdenv.cc.cc.lib libx11 libxcursor]}"
      '';
    })
    # system
    btop sysstat lm_sensors ethtool pciutils usbutils powertop killall ipset
    gparted seahorse baobab scrcpy fastfetch zenity mullvad-vpn easyeffects
    pavucontrol my.iterator-icons
    # debug
    strace ltrace lsof helvum
    # apps
    (vivaldi.override { proprietaryCodecs = true; })
    telegram-desktop onlyoffice-desktopeditors mpv qalculate-gtk krita
    inkscape obsidian vlc kdePackages.kdenlive audacity aseprite imhex
    jetbrains.rider lrcget picard blockbench archipelago signal-desktop
    (blender.override { rocmSupport = true; }) poptracker my.mxlrc-go
    my.arrowvortex
      # i feel like these should just be rider dependencies
      dotnet-sdk mono
    # compatilibility
    wineWow64Packages.stable winetricks
    # misc
    cowsay file which tree gnused yt-dlp libnotify font-manager wev
    lua54Packages.lua tauon nicotine-plus transmission_4-gtk
    nodejs_latest inputs.pond.packages.${system}.pond
    # love2d (to be moved elsewhere)
    love my.love-release my.love-js
    # games
    gale (olympus.override { celesteWrapper = "steam-run"; })
    my.loenn my.tetrio-desktop easyrpg-player
    (prismlauncher.override {
      additionalPrograms = [ vlc ];
      additionalLibs = [ vlc ];
    })
    (ringracers.overrideAttrs {
      src = pkgs.fetchFromGitHub {
        owner = "Superstarxalien";
        repo = "RadioRacers";
        rev = "c52f3e332c57d4c8c58e0b014aede8e02d8bb7a7";
        hash = "sha256-u69DCQGoLO6R2rd3JGo+l1L60cQZKcPVx5rpWqwGUaQ=";
      };
    })
    vintagestory my.casual-pre-loader vtfedit my.rust-vpk
    # my.tomodachi-texture-tool
    inputs.ryubing.packages.${system}.default

    # plugins & audio
    vital resonarium my.glitch2
    yabridge yabridgectl
    my.nih-plug
    # i love pirating software
    (let
      bitwigCracked = requireFile {
        name = "bitwig.jar";
        url = "https://rutracker.org/forum/viewtopic.php?t=6828832";
        sha256 = "2ae8d9537875fce96e53c4313d1fd03e5cf6c12d63de54b95b18fccc1bca58b4";
      };
    in inputs.bitwig.legacyPackages.${system}.bitwig-studio6.overrideAttrs (final: prev: {
      postFixup = prev.postFixup + ''
        cp ${bitwigCracked} "$out"/libexec/bin/bitwig.jar
        rm -rf "$out"/libexec/lib/jre
        ln -s ${openjdk25}/lib/openjdk/ "$out"/libexec/lib/jre
      '';
    }))
  ] ++ (with pkgs.gnome; [
    # these are usually defaults, but are missing when non-gnome DEs are used
    # however gnome apps are my beloved so i'm just adding them back
    nautilus gnome-system-monitor pkgs.loupe gnome-disk-utility pkgs.gedit
    file-roller
  ]);

  environment.systemPackages = [
    # make this globally available for silly bullshit
    bridgewebhook
  ];

  fileSystems."/home/oatmealine/downloads" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "size=2G" "mode=777" ];
  };

  # work around a really annoying systemd issue
  #systemd.extraConfig = "DefaultTimeoutStopSec=10s";
  #systemd.user.extraConfig = "DefaultTimeoutStopSec=10s";

  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-vkcapture
      obs-pipewire-audio-capture
      input-overlay
    ];
    enableVirtualCamera = true;
  };

  programs.ssh = {
    package = pkgs.openssh_hpn;
  };

  #services.earlyoom.enable = true;
  #services.earlyoom.freeMemThreshold = 5;
  #services.earlyoom.enableNotifications = true;
  #services.earlyoom.extraArgs = [
  #  "--avoid"
  #  ''^(nix|wezterm-gui|Xwayland|niri|pipewire-pulse|pipewire|wireplumber)$''
  #  "--prefer"
  #  ''^(steam|steamwebhelper|\.Discord-wrappe|vivaldi-bin)$''
  #];

  services.mullvad-vpn.enable = true;

  # ideally always off for my own sanity
  #hm.services.podman.enable = true;
  # sometimes i enable this for testing
  #services.postgresql.enable = true;

  # move this out someday aswell i think
  hm.services.easyeffects.enable = true;

  # fix audio plugins (also move this out)
  # https://nixos.wiki/wiki/Audio_production
  environment.sessionVariables = let
    makePluginPath = format:
      (lib.makeSearchPath format [
        "$HOME/.nix-profile/lib"
        "/run/current-system/sw/lib"
        "/etc/profiles/per-user/$USER/lib"
      ])
      + ":$HOME/.${format}";
  in {
    DSSI_PATH   = makePluginPath "dssi";
    LADSPA_PATH = makePluginPath "ladspa";
    LV2_PATH    = makePluginPath "lv2";
    LXVST_PATH  = makePluginPath "lxvst";
    VST_PATH    = makePluginPath "vst";
    VST3_PATH   = makePluginPath "vst3";
  };

  modules = {
    #ssh.enable = true;

    security.useDoas = true;
    #security.useDoas = false; # required for xray ?!? (solved: no longer using xray :))
    os-release = {
      enable = true;
      logo = "color-five-pebbles";
    };

    hardware = {
      mdrop.enable = true;
      pipewire.enable = true;
    };
    dev = {
      enable = true;
      #crystal.enable = true;
    };
    desktop = {
      envProto = "wayland";

      niri.enable = true;
      awww.enable = true;
      awww.blurredDuplicate = true;
      #hypridle.enable = true;
      #hypridle.desktop = true;

      mako.enable = true;
      mako.osd = true;
      waybar.enable = true;
      waybar.hostname = "five-pebbles";
      rofi.enable = true;
      #cliphist.enable = true;
      #clipse.enable = true;
      #fuzzel.enable = true;
      vicinae.enable = true;

      sddm.enable = true;
      sddm.autologin = true;

      themes.active = "catppuccin";
    };
    software = {
      # system
      #system.amnezia.enable = true;
      system.audiorelay.enable = true;
      system.kdeconnect.enable = true;
      system.wezterm.enable = true;
      system.fish.enable = true;
      system.syncthing.enable = true;
      #system.system76-scheduler.enable = true;
      system.flatpak.enable = true;
      system.virt-manager.enable = true;
      #system.zapret.enable = true;
      #system.zapret.params = [
      #  "--hostspell=hoSt"
      #  "--dpi-desync=fakeddisorder --dpi-desync-ttl=2 --dpi-desync-split-pos=midsld"
      #];
      # dev
      dev.git.enable = true;
      dev.direnv.enable = true;
      # editors
      editors.vscode.enable = true;
      editors.micro.enable = true;
      # tools
      tools.rbw.enable = true;
      #tools.noisetorch.enable = true;
      #tools.noisetorch.autostart = {
      #  enable = true;
      #  device.name = "alsa_input.usb-3142_fifine_Microphone-00.analog-stereo";
      #  device.unit = "sys-devices-pci0000:00-0000:00:14.0-usb1-1\\x2d2-1\\x2d2.1-1\\x2d2.1:1.0-sound-card0-controlC0.device";
      #};
      # distractions
      distractions.steam.enable = true;
      distractions.steam.gamemode = true;
      distractions.steam.gamescope = true;
      distractions.steam.millennium = true;
      distractions.discord.enable = true;
      distractions.discord.vencord.enable = true;
      #distractions.discord.vesktop.enable = true;
      #distractions.discord.openasar.enable = true;
    };
  };
}

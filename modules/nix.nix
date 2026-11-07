{ lib, pkgs, inputs, config, system, ... }:
let
  nixpkgs = inputs.nixpkgs;
in {
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # defaults
    zlib
    zstd
    stdenv.cc.cc
    curl
    openssl
    attr
    libssh
    bzip2
    libxml2
    acl
    libsodium
    util-linux
    xz
    systemd
    
    # nixos wiki: common GUI deps
    libxcomposite
    libxtst
    libxrandr
    libxext
    libx11
    libxfixes
    libGL
    libva
    pipewire
    libxcb
    libxdamage
    libxshmfence
    libxxf86vm
    libelf
    glib
    gtk2
    libxinerama
    libxcursor
    libxrender
    libxscrnsaver
    libxi
    libsm
    libice
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    gtk3
    icu
    libnotify
    gsettings-desktop-schemas
    libxt
    libxmu

    # nixos wiki: similar to steam's
    networkmanager      
    vulkan-loader
    libgbm
    libdrm
    libxcrypt
    coreutils
    pciutils
    zenity
    # glibc_multi.bin # Seems to cause issue in ARM

    # nixos wiki: common for games
    libogg
    libvorbis
    SDL
    SDL2_image
    libidn
    flac
    freeglut
    libjpeg
    libpng
    #libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex

    # nixos wiki: misc
    pango
    cairo
    atk
    gdk-pixbuf
    fontconfig
    freetype
    dbus
    alsa-lib
    expat
    libxkbcommon
    libxcrypt-legacy
    libGLU

    # tauri
    nghttp2
    webkitgtk_4_1
    libsecret
    at-spi2-atk
    e2fsprogs
    glib-networking
  ];
  
  environment.systemPackages = with pkgs; [
    inputs.nix-alien.packages.${system}.nix-alien
  ];

  /*
  nix.registry.nixpkgs = {
    from = {
      id = "nixpkgs";
      type = "indirect";
    };
    to = lib.mkForce {
      path = "${nixpkgs}";
      type = "path";
    };
  };
  */

  nix.registry = let
    flakes = lib.filterAttrs (name: value: value ? outputs) inputs;
  in builtins.mapAttrs
    (name: v: { flake = v; })
    flakes;

  systemd.tmpfiles.rules = [
    "d   /root/.nix-defexpr        0755  root  root  -  -"
    "L+  /root/.nix-defexpr/nixos     -     -        -  -  ${nixpkgs}"
    "L+  /root/.nix-defexpr/nixpkgs   -     -        -  -  ${nixpkgs}"
  ];

  environment.etc = (lib.mapAttrs'
    (name: value: { name = "nix/inputs/${name}"; value = { source = value.outPath; }; })
    inputs);

  nix.nixPath = [ "/etc/nix/inputs" ];

  environment.extraInit = ''
    export NIX_PATH="nixpkgs=${nixpkgs}"
  '';

  programs.command-not-found.enable = false;
  hm.programs.nix-index.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  nix.optimise.automatic = true;
  #nix.gc = {
  #  automatic = true;
  #  dates = "weekly";
  #  options = "--delete-older-than 14d";
  #};
}

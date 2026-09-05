# shamelessly stolen from https://github.com/cerisyl/nix/blob/main/nixos/customs/deps/arrowvortex/FindAubio.cmake

{ 
  stdenv, lib, fetchFromGitHub, makeDesktopItem, copyDesktopItems, makeWrapper,
  alsa-lib, fribidi, pulseaudio, libx11, libxext, libxrandr, libxcursor,
  libxfixes, libxi, libxscrnsaver, libxtst, dbus, ibus, systemd, mesa,
  libxkbcommon, vulkan-headers, vulkan-loader, wayland, wayland-protocols,
  libdrm, libusb1, libdecor, pipewire, libthai, liburing,
  cmake, ninja, pkg-config,
  aubio, ffmpeg, freetype, iir1, libmad, libogg, libGL, sdl3, stb, libvorbis
}: let
  name    = "arrowvortex";
  version = "a77b1c47ebe58d6f9af4f36493c1b5ea8923f259";
in stdenv.mkDerivation rec {
  inherit name version;
  arch = "amd64";
  nativeBuildInputs = [ cmake ninja pkg-config copyDesktopItems makeWrapper ];
  buildInputs = [
    alsa-lib fribidi pulseaudio libx11 libxext libxrandr libxcursor
    libxfixes libxi libxscrnsaver libxtst dbus ibus systemd mesa
    libxkbcommon vulkan-headers vulkan-loader wayland wayland-protocols
    libdrm libusb1 libdecor pipewire libthai liburing
    # vcpkg deps
    aubio ffmpeg freetype iir1 libmad libogg libGL sdl3 stb libvorbis
  ];

  src = fetchFromGitHub {
    owner = "uvcat7";
    repo  = name;
    rev   = version;
    hash  = "sha256-4iHdaL9GyXfdIlvigTvdnM1GB0ESvw4tEHDaPcXSuLA=";
  };

  cmakeFlags = [
    "-DPRESET_NAME=linux-release"
    "-DCMAKE_TOOLCHAIN_FILE=${./blank.cmake}"
  ];

  # Patch cmake files to work with Nix
  postPatch = ''
    cp ${./FindAubio.cmake} cmake/FindAubio.cmake
    cp ${./FindFFMPEG.cmake} cmake/FindFFMPEG.cmake
    cp ${./FindStb.cmake} cmake/FindStb.cmake

    substituteInPlace CMakeLists.txt --replace-fail \
      'find_package(Aubio CONFIG NAMES aubio Aubio)' \
      'find_package(Aubio MODULE)'
    substituteInPlace CMakeLists.txt --replace-fail \
      'set(CMAKE_CXX_CLANG_TIDY "clang-tidy;''${tidy_flags}''${tidy_extra}-p=build")' \
      ""
  '';

  # Build/install
  buildPhase = ''
    cmake --build .
  '';
  installPhase = ''
    cmake --install . --prefix "$out"
    runHook postInstall
  '';

  # Patch in preferred assets, create icon, .desktop file
  # Ensure AV gets wrapped to run in the bin folder

  # cp -f ${../../extra/itg/beattick.wav} "$out/bin/assets/sound beat tick.wav"
  # cp -f ${../../extra/itg/notetick.wav} "$out/bin/assets/sound note tick.wav"
  postInstall = ''
    mv $out/bin/ArrowVortex $out/bin/arrowvortex

    mkdir -p $out/share/icons/hicolor/256x256/apps
    ln -s "$out/bin/assets/arrow vortex icon.png" $out/share/icons/hicolor/256x256/apps/arrowvortex.png

    wrapProgram $out/bin/arrowvortex --run 'cd "'"$out"'/bin"'
  '';
  desktopItems = [
    (makeDesktopItem {
      name = "arrowvortex";
      desktopName = "ArrowVortex";
      genericName = "File editor";
      exec = "arrowvortex";
      terminal = false;
      icon = "arrowvortex";
      type = "Application";
      comment = "A graphical editor for .sm/.ssc files.";
      startupWMClass = ".arrowvortex-wrapped";
    })
  ];

  meta = with lib; {
    homepage = "https://arrowvortex.ddrnl.com/";
    description = "Stepmania .sm/.ssc file development tool";
    platforms = platforms.linux;
    license = licenses.gpl3Only;
    #maintainers = with maintainers; [ cerisyl ];
    mainprogram = "arrowvortex";
  };
}
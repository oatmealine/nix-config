{
  lib,
  buildDotnetModule,
  cctools,
  darwin,
  dotnetCorePackages,
  fetchFromGitHub,
  libx11,
  libgdiplus,
  moltenvk,
  ffmpeg,
  openal,
  libsoundio,
  sndio,
  stdenv,
  pulseaudio,
  vulkan-loader,
  glew,
  libGL,
  libice,
  libsm,
  libxcursor,
  libxext,
  libxi,
  libxrandr,
  udev,
  SDL2,
  SDL2_mixer,
  gtk3,
  wrapGAppsHook3,
}:

buildDotnetModule rec {
  pname = "living-the-dream-save-editor";
  version = "1.0.31";

  src = fetchFromGitHub {
    owner = "tlmodding";
    repo = "living-the-dream-save-editor";
    rev = "e19ea9320cb347f0658bb8b805adf3f289270b04";
    hash = "sha256-nnT1MdHboWcxAfBy/8BHDSecbR0SMKcDVUWXBBzdeN0=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
  ];

  enableParallelBuilding = false;

  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;

  nugetDeps = ./deps.json;

  runtimeDeps = [
    libx11
    libgdiplus
    SDL2_mixer
    openal
    libsoundio
    sndio
    vulkan-loader
    ffmpeg

    # Avalonia UI
    glew
    libice
    libsm
    libxcursor
    libxext
    libxi
    libxrandr
    gtk3

    # Headless executable
    libGL
    SDL2
    udev
    pulseaudio
  ];

  projectFile = "LTDSaveEditor.Avalonia/LTDSaveEditor.Avalonia.csproj";

  doCheck = false;

  makeWrapperArgs = [
    "--set SDL_VIDEODRIVER x11"
  ];

  /*preInstall = ''
    # workaround for https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6
  '';*/

  /*preFixup = ''
    mkdir -p $out/share/{applications,icons/hicolor/scalable/apps,mime/packages}

    pushd ${src}/distribution/linux

    install -D ./Ryujinx.desktop  $out/share/applications/Ryujinx.desktop
    install -D ./Ryujinx.sh       $out/bin/Ryujinx.sh
    install -D ./mime/Ryujinx.xml $out/share/mime/packages/Ryujinx.xml
    install -D ../misc/Logo.svg   $out/share/icons/hicolor/scalable/apps/Ryujinx.svg

    popd
  '';*/
}

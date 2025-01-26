{ lib
, buildDotnetModule
, dotnetCorePackages
, fetchFromGitHub
, libX11
, libgdiplus
, ffmpeg
, openal
, libsoundio
, sndio
, pulseaudio
, vulkan-loader
, glew
, libGL
, libICE
, libSM
, libXcursor
, libXext
, libXi
, libXrandr
, udev
, SDL2
, SDL2_mixer
}:

buildDotnetModule rec {
  pname = "ryujinx";
  version = "1.2.81";

  src = fetchFromGitHub {
    owner = "Ryubing";
    repo = "Ryujinx";
    rev = "1.2.81";
    hash = "sha256-P/lTXhdSXhoseBYC5NcSZDCQCUL9z2yt5LuGj8V0BdU=";
  };

  enableParallelBuilding = false;

  dotnet-sdk = dotnetCorePackages.dotnet_9.sdk;
  dotnet-runtime = dotnetCorePackages.dotnet_9.runtime;

  nugetDeps = ./deps.json;

  runtimeDeps = [
    libX11
    libgdiplus
    SDL2_mixer
    openal
    libsoundio
    sndio
    pulseaudio
    vulkan-loader
    ffmpeg
    udev

    # Avalonia UI
    glew
    libICE
    libSM
    libXcursor
    libXext
    libXi
    libXrandr

    # Headless executable
    libGL
    SDL2
  ];

  projectFile = "Ryujinx.sln";
  testProjectFile = "src/Ryujinx.Tests/Ryujinx.Tests.csproj";
  doCheck = true;

  dotnetFlags = [
    "/p:ExtraDefineConstants=DISABLE_UPDATER%2CFORCE_EXTERNAL_BASE_DIR"
  ];

  executables = [
    #"Ryujinx.Headless.SDL2"
    "Ryujinx"
  ];

  makeWrapperArgs = [
    # Without this Ryujinx fails to start on wayland. See https://github.com/Ryujinx/Ryujinx/issues/2714
    "--set SDL_VIDEODRIVER x11"
  ];

  preInstall = ''
    # workaround for https://github.com/Ryujinx/Ryujinx/issues/2349
    mkdir -p $out/lib/sndio-6
    ln -s ${sndio}/lib/libsndio.so $out/lib/sndio-6/libsndio.so.6
  '';

  preFixup = ''
    mkdir -p $out/share/{applications,icons/hicolor/scalable/apps,mime/packages}
    pushd ${src}/distribution/linux

    install -D ./Ryujinx.desktop $out/share/applications/Ryujinx.desktop
    install -D ./Ryujinx.sh $out/bin/Ryujinx.sh
    install -D ./mime/Ryujinx.xml $out/share/mime/packages/Ryujinx.xml
    install -D ../misc/Logo.svg $out/share/icons/hicolor/scalable/apps/Ryujinx.svg

    substituteInPlace $out/share/applications/Ryujinx.desktop \
      --replace "Ryujinx.sh %f" "$out/bin/Ryujinx.sh %f"

    ln -s $out/bin/Ryujinx $out/bin/ryujinx

    popd
  '';

  passthru.updateScript = ./updater.sh;

  meta = with lib; {
    mainProgram = "Ryujinx";
  };
}
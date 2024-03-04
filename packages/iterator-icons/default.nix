{ stdenv, ... }:

stdenv.mkDerivation {
  pname = "iterator-icons";
  version = "0.0.0";

  src = ./.;

  dontDropIconThemeCache = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons/hicolor/256x256/apps/
    cp -a ./icons/* $out/share/icons/hicolor/256x256/apps/
    runHook postInstall
  '';
}
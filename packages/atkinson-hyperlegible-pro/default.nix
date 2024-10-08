{ lib, stdenvNoCC, fetchFromGitHub, ... }:

stdenvNoCC.mkDerivation {
  pname = "atkinson-hyperlegible-pro";
  version = "1.5.1-unstable";

  src = fetchFromGitHub {
    owner = "jacobxperez";
    repo = "atkinson-hyperlegible-pro";
    rev = "2576e71d09f57eac8d5e7d9d42b9e7ce49f759e1";
    hash = lib.fakeHash;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype fonts/otf/*

    runHook postInstall
  '';

  meta = with lib; {
    description = "Maintained version of Atkinson Hyperlegible";
    homepage = "https://jacobxperez.github.io/atkinson-hyperlegible-pro/";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
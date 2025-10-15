{
  lib,
  stdenv,
  fetchFromGitHub,
  libpng,
  glib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vtf2png";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "eXeC64";
    repo = "vtf2png";
    rev = "e74a1fd24b760a0339ec4d498d0b9fef75d847ff";
    hash = "sha256-/tfhTMQNBh6RVe55QyYjG3ns0w0/E/afF7aB2lAp/f4=";
  };

  installPhase = ''
    install -vD vtf2png $out/bin/vtf2png
  '';

  buildInputs = [
    libpng
    glib
  ];
})
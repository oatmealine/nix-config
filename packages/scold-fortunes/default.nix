{ stdenv, pkgs }:

stdenv.mkDerivation {
  pname = "scold-fortunes";
  version = "0.0.1710273980";

  src = ./.;

  nativeBuildInputs = with pkgs; [ fortune ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/fortune/
    strfile ./fortunes/*.fortune
    cp -a ./fortunes/* $out/share/fortune/
    runHook postInstall
  '';
}
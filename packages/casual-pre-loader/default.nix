{ lib,
  pkgs,
  fetchFromGitHub
}:

with pkgs;

let
  pythonPath = python3.withPackages (
    ps:
    with ps;
    [ pyqt6 pillow pyxdg ]
  );
in
stdenv.mkDerivation rec {
  pname = "casual-pre-loader";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "cueki";
    repo = "casual-pre-loader";
    rev = "234c95c7cb2783dcfa66fb850bce7c58d77bed65";
    hash = "sha256-8XuSdK+qwksfbE5nXkBqhM0PGKY1o6l2ZiBLiz1HxSw=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  installPhase = ''
    mkdir -p $out
    printf '%s\n' 'portable = False' >core/are_we_portable.py
    mv ./* $out/
    makeWrapper ${pythonPath}/bin/python $out/bin/casual-pre-loader \
      --add-flags $out/main.py
  '';
}
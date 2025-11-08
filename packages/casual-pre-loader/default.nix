{ lib,
  pkgs,
  fetchFromGitHub
}:

with pkgs;
with pkgs.python3Packages;

let
  valve-parsers = buildPythonPackage rec {
    pname = "valve-parsers";
    version = "1.0.7";
    src = fetchPypi {
      pname = "valve_parsers";
      inherit version;
      sha256 = "sha256-/3hV1+niFs7YrpI+xtTbN5Zc/87jgryMWb6ruG+Hnmo=";
    };
    format = "pyproject";
    propagatedBuildInputs = [
      setuptools
    ];
  };
  pythonPath = python3.withPackages (
    ps:
    with ps;
    [ pyqt6 valve-parsers requests packaging platformdirs ]
  );
in
stdenv.mkDerivation rec {
  pname = "casual-pre-loader";
  version = "1.6.6";

  src = fetchFromGitHub {
    owner = "cueki";
    repo = "casual-pre-loader";
    rev = "11993ea06f07be6b3345094bfdd2565a0fb7db1f";
    hash = "sha256-DIt8Z6DatBwIIfQ+48BRCboF30SuQaSp89x1mO1GJio=";
  };

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  dontCheckForBrokenSymlinks = true;

  installPhase = ''
    mkdir -p $out
    printf '%s\n' 'portable = False' >core/are_we_portable.py
    mv ./* $out/
    makeWrapper ${pythonPath}/bin/python $out/bin/casual-pre-loader \
      --add-flags $out/main.py
  '';
}
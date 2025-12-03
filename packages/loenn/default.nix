{ lib,
  pkgs,
  fetchFromGitHub,
  love,
  luajitPackages,
  makeDesktopItem,
  stdenv,
  fetchzip
}:

let
  lua_cpath =
    with luajitPackages;
    lib.concatMapStringsSep ";" getLuaCPath [
      nfd
    ];
in stdenv.mkDerivation rec {
  pname = "loenn";
  version = "1.0.5";

  src = fetchFromGitHub {
    owner = "CelestialCartographers";
    repo = "Loenn";
    rev = "v${version}";
    hash = "sha256-1srNPJ6xaOWQM18RwTzajWPm/xfUTS/qV/NNYGeeHss=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    mkdir -p $out/lib/loenn/

    printf '%s' 'Lönn' >src/assets/TITLE
    printf '%s' '${version}' >src/assets/VERSION
    cp ${loveArchive}/assets/loading-256.png src/assets/loading-256.png
    cp ${loveArchive}/assets/logo-256.png src/assets/logo-256.png

    mv ./src/* $out/lib/loenn/

    makeWrapper ${lib.getExe love} $out/bin/loenn \
      --prefix LUA_CPATH ";" "${lua_cpath}" \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ pkgs.curl ]}" \
      --set SDL_VIDEODRIVER x11 \
      --add-flags $out/lib/loenn/ \
      --add-flags "--fused"

    install -Dm644 ${desktopEntry}/share/applications/loenn.desktop $out/share/applications/loenn.desktop
    install -Dm644 ${loveArchive}/assets/logo-256.png $out/share/icons/hicolor/256x256/apps/loenn.png
    install -Dm644 LICENSE $out/share/licenses/loenn/LICENSE
  '';

  # used for grabbing the icon. SORRY.
  loveArchive = fetchzip {
    name = "Loenn-v${version}.love";
    url = "https://github.com/CelestialCartographers/Loenn/releases/download/v${version}/Loenn-v${version}.love";
    hash = "sha256-cY/GbrHDEbVuNc4pnuFJn71ko3aY38jXglSK7VUdHkw=";
    extension = "zip";
    stripRoot = false;
  };

  desktopEntry = makeDesktopItem {
    name = "loenn";
    desktopName = "Lönn";
    exec = "loenn";
    icon = "loenn";
    comment = "A Visual Map Maker and Level Editor for the game Celeste but better than the other one";
    categories = [ "Development" "Utility" ];
  };
}
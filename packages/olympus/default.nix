# Borrowed from https://raw.githubusercontent.com/VergeDX/config-nixpkgs/341684da8ccb6699fad399b998aa0caad723d882/packages/gui/olympus.nix

{ pkgs, makeDesktopItem }:
let
  olympus = pkgs.stdenv.mkDerivation rec {
    pname = "olympus";
    version = "3813";

    # https://everestapi.github.io/
    src = pkgs.fetchzip {
      url = "https://dev.azure.com/EverestAPI/Olympus/_apis/build/builds/${version}/artifacts?artifactName=linux.main&$format=zip#linux.main.zip";
      hash = "sha256-thnHPPsuUne0zX1Fx+BjQiOoKseXDDUIvrczhOdSZmY=";
    };

    buildInputs = [ pkgs.unzip pkgs.makeWrapper ];
    installPhase = ''
      mkdir -p "$out/opt/olympus/"
      mv dist.zip "$out/opt/olympus/" && cd "$out/opt/olympus/"

      unzip dist.zip && rm dist.zip
      mkdir $out && echo XDG_DATA_HOME=$out

      echo y | XDG_DATA_HOME="$out/share/" bash install.sh
      rm ./love
      rm ./find-love
      cp ${pkgs.love}/bin/love ./find-love

      sed -i "s/Exec=.*/Exec=olympus %u/g" ../../share/applications/Olympus.desktop
    '';
  };
in
pkgs.buildFHSEnv {
  name = "olympus";
  runScript = "${olympus}/opt/olympus/olympus";
  targetPkgs = pkgs: [
    pkgs.freetype
    pkgs.zlib
    pkgs.SDL2
    pkgs.curl
    pkgs.libpulseaudio
    pkgs.gtk3
    pkgs.glib
    pkgs.xdg-utils
    pkgs.icu
    pkgs.openssl
  ];

  # https://github.com/EverestAPI/Olympus/blob/main/lib-linux/olympus.desktop
  # https://stackoverflow.com/questions/8822097/how-to-replace-a-whole-line-with-sed
  extraInstallCommands = ''cp -r "${olympus}/share/" $out'';
}
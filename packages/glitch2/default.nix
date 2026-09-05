{ pkgs }:

pkgs.stdenv.mkDerivation {
  name = "glitch2";
  src = pkgs.fetchurl {
    url = "https://illformed.com/downloads/Glitch_2_1_5_Linux_Free.zip";
    hash = "sha256-dHHKyG3odP59gDRND2ZE/c3eRxMQj6dvgJ7E9lgTd88=";
  };
  
  nativeBuildInputs = with pkgs; [ autoPatchelfHook unzip ];
  buildInputs = with pkgs; [
    stdenv.cc.cc
    stdenv.cc.cc.lib
    alsa-lib
    libx11
    libxext
  ];

  unpackPhase = ''
    unzip "$src" -x /
  '';

  installPhase = ''
    mkdir -p $out/lib/vst3/
    cp -r glitch2.vst3 $out/lib/vst3/
  '';
}
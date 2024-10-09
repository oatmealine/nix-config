{ lib, stdenvNoCC }:

stdenvNoCC.mkDerivation {
  pname = "rain-world-menu-font";
  version = "1.0.0";

  # https://fontstruct.com/font_archives/download/2392353
  # https://fontstruct.com/font_archives/download/2392353/otf
  
  src = ./.;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype ./rain-world-menu.otf

    runHook postInstall
  '';

  meta = with lib; {
    #description = "Maintained version of Atkinson Hyperlegible";
    homepage = "https://fontstruct.com/fontstructions/show/2392353/rain-world-menu";
    #license = licenses.ofl; # FontStruct Non-Commercial Software End User License Agreement 1.0
    platforms = platforms.all;
  };
}
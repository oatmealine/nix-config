{
  lib,
  stdenv,
  fetchurl,
}:

let
  twemoji-colr-otf = fetchurl {
    url = "https://y12.nekoweb.org/twemoji-colr/pre/release/TwemojiCOLR.otf";
    hash = "sha256-qv3nzNcYwmM4V2suLe5NTgbYSF10Z+lTIRNBrTP7B6E=";
  };
  twemoji-colr-applecoloremoji-otf = fetchurl {
    url = "https://y12.nekoweb.org/twemoji-colr/pre/release/TwemojiCOLR_renamed_AppleColorEmoji.otf";
    hash = "sha256-pP+VHuK28kj6xuMQDFCsgwc38VeexOPGOgOSXZ3RrUc=";
  };
in stdenv.mkDerivation {
  name = "twemoji-colr";
  version = "16.0.10-pre";

  src = ./.;

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype ${twemoji-colr-otf}
    install -Dm644 -t $out/share/fonts/opentype ${twemoji-colr-applecoloremoji-otf}

    runHook postInstall
  '';
}

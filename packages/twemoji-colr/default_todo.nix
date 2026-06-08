{
  fetchFromGitHub,
  lib,
  nodejs-slim,
  fontforge,
  python3Packages,
  stdenv,
  fetchurl,
  fetchpatch,
}:

# TODO: fix build
# unsure how they got theirs to work.. i'm just getting cool python errors
# fontTools.colorLib.errors.ColorLibError: populateCOLRv0: base glyph(s) not found in glyphMap: u20E3, u0030, u0031, u0032, u0033, u0034, u0035, u0036, u0037, u0038 (and 3 more)

let
  unicode-emoji-test = fetchurl {
    url = "https://www.unicode.org/Public/emoji/16.0/emoji-test.txt";
    hash = "sha256-JPDFNOhs8ULiSWlT6PDkaj5wI5KRHt3NKcbM7YUTlpc=";
  };
  twemoji = fetchFromGitHub {
    owner = "12Me21";
    repo = "twemoji-fix-ellipses";
    rev = "6bddb4a978335d9bdfcc66c2f32f985a219019dc";
    hash = "sha256-W/kK3YJy3qCy+6NKdmXbh13Vajgu2t1HsIvT5MivVXY=";
  };
in stdenv.mkDerivation {
  name = "twemoji-colr";
  version = "16.0.10-pre";

  src = fetchFromGitHub {
    owner = "12Me21";
    repo = "twemoji-COLR";
    rev = "b173454b16ec0871afc62935678142d9b31267fe";
    hash = "sha256-2NefBVK54n0CRudmC3JZktk0F2ImQpvrFaqL7wupkmo=";
  };

  nativeBuildInputs = [ nodejs-slim fontforge python3Packages.fonttools ];

  postUnpack = ''
    cp ${unicode-emoji-test} source/data/unicode-emoji-test.txt
    cp -r ${twemoji} source/data/twemoji
  '';

  patchPhase = ''
    substituteInPlace Makefile \
      --replace-fail \
      "build/layers.json build/glyphs.json: build/edata.json scripts/layerize.js scripts/xml.js scripts/read-svg.js twemoji/assets/svg" \
      "build/layers.json build/glyphs.json: build/edata.json scripts/layerize.js scripts/xml.js scripts/read-svg.js"
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 -t $out/share/fonts/opentype build/*.otf

    runHook postInstall
  '';
}

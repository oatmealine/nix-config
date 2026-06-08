
{
  lib,
  stdenv,
  rustPlatform,
  fetchNpmDeps,
  cargo-tauri,
  glib-networking,
  nodejs,
  npmHooks,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,
  fetchFromGitHub,
  icoutils,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "tomodachi-texture-tool";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "farbensplasch";
    repo = "tomodachi-texture-tool";
    rev = "485846fc567bf0b28e46d4d067821219891576c2";
    hash = "sha256-0Y4mawjBM4WXbCu5l9aRPQxmxkSpDlY7eYMtKAd8WxU=";
  };

  cargoHash = "sha256-teUOdsIaYSw5poOiOUCmyCKm6ws7Lz+lD/SCUpmAY50=";

  # Assuming our app's frontend uses `npm` as a package manager
  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit (finalAttrs) src;
    hash = "sha256-RyMWNpZKYL/HkCrhhgaHSQPZdtPd3Gwg3kInbVHfQ3M=";
  };

  nativeBuildInputs = [
    # Pull in our main hook
    cargo-tauri.hook

    # Setup npm
    nodejs
    npmHooks.npmConfigHook

    # Make sure we can find our libraries
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    #glib-networking # Most Tauri apps need networking
    openssl
    webkitgtk_4_1
  ];

  patchPhase = ''
    runHook prePatch

    ${icoutils}/bin/icotool -x -i 1 src-tauri/icons/icon.ico -o src-tauri/icons/icon.png

    runHook postPatch
  '';

  # Set our Tauri source directory
  cargoRoot = "src-tauri";
  # And make sure we build there too
  buildAndTestSubdir = finalAttrs.cargoRoot;
})

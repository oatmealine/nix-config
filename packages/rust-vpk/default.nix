{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,

  pkg-config, fuse,
}:

rustPlatform.buildRustPackage rec {
  pname = "rust-vpk";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "panzi";
    repo = "rust-vpk";
    rev = "158c831d26b70793ffb56e883d9915720f78440c";
    hash = "sha256-StmYuYZI2ONd31bZ+iznVMwf22Rceruhx1Z+yrRxrS8=";
  };

  cargoHash = "sha256-xKJGBhuKONWsMLtFoO8wFAsIaR6tXhzdxVp7RlABOeo=";

  doCheck = false;

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ fuse ];

  meta = {
    mainProgram = "rvpk";
  };
}
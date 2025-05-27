{
  lib,
  rustPlatform,
  fetchFromGitHub,
  stdenv,
}:

rustPlatform.buildRustPackage rec {
  pname = "sdfgen";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ConnyOnny";
    repo = "sdfgen";
    rev = "f05813b8b2e4eb9ae5e6516c0b064a464fd6e2e1";
    hash = "sha256-2PlUlMz63Ot/doMf/HULRr2I+O8L7TjkbOJXUrTymV4=";
  };

  cargoHash = "sha256-AKziEwkHTVk0Q10eUWYIwkcUMrhXbWlZQ2qDYTXJ30s=";

  doCheck = false;
}
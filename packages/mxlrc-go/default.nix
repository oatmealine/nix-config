{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mxlrc-go";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "fashni";
    repo = "mxlrc-go";
    rev = "9dbd4755546fc2cae416271a3b1102835a1764fe";
    hash = "sha256-jPCTCp57UXHiFwNbzoZJymkCSN8rV670hoRZ45w1mrU=";
  };

  vendorHash = "sha256-Brxl+YKr/nlEyDKhJmuHNXSgmiphnO/43xlwodJ/RBY=";

  #ldflags = ["-s" "-w" "-X github.com/juanfont/headscale/cmd/headscale/cli.Version=v${version}"];

  #nativeBuildInputs = [installShellFiles];
  #checkFlags = ["-short"];
}
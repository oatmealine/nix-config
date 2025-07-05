{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage rec {
  pname = "love-js";
  version = "unstable-2024-05-13";

  src = fetchFromGitHub {
    owner = "Davidobot";
    repo = "love.js";
    rev = "c4f04e185033a7c9fbefa9be3bec88c41a90421b";
    hash = "sha256-EHCU5RSk7ei5PX1eS/aPiRe5jtQUlewX7cF0Lj4+E1o=";
  };

  dontNpmBuild = true;
  dontCheckForBrokenSymlinks = true;

  npmDepsHash = "sha256-MqQM2beiakNuhGgkOzlPSlTqg8oltGWLgG8D+KyIkmU=";
}
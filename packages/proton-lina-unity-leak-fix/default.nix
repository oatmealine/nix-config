{ lib
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "proton-lina-unity-fix";
  version = "v5-tkg-xbe-proton-11.0-1-beta5";

  src = fetchzip {
    url = "https://github.com/madalee-com/wine-tkg-git-lina-unity-leak-fix/releases/download/${version}/Proton-Lina-Unity-Leak-Patch-v5-XBE.tar.gz";
    hash = "sha256-tUYXHEo/VQ1m7pVOdeWVph6eTgKVE5uykZVK878v7Rg=";
  };

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall

    # Make it impossible to add to an environment. You should use the appropriate NixOS option.
    # Also leave some breadcrumbs in the file.
    echo "${name} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool

    runHook postInstall
  '';

  meta = with lib; {
    description = "The wine-tkg build systems, to create custom Wine and Proton builds, with Lina's Unity leak patch";
    homepage = "https://github.com/madalee-com/wine-tkg-git-lina-unity-leak-fix";
    platforms = [ "x86_64-linux" ];
  };
}

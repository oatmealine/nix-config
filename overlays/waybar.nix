final: prev: {
  waybar = prev.waybar.overrideAttrs ( old: {
    version = "0.10.0";

    src = prev.fetchFromGitHub {
      owner = "Alexays";
      repo = "Waybar";
      rev = "0.10.0";
      hash = "sha256-p1VRrKT2kTDy48gDXPMHlLbfcokAOFeTZXGzTeO1SAE=";
    };

    # fix gtk-layer-shell issue
    mesonFlags = builtins.filter (a: !(prev.lib.strings.hasInfix "gtk-layer-shell" a)) old.mesonFlags;

    # fix cava version mismatch issue
    postUnpack = let 
      # Derived from subprojects/cava.wrap
      libcava.src = prev.fetchFromGitHub {
        owner = "LukashonakV";
        repo = "cava";
        rev = "0.10.1";
        hash = "sha256-iIYKvpOWafPJB5XhDOSIW9Mb4I3A4pcgIIPQdQYEqUw=";
      };
    in ''
      pushd "$sourceRoot"
      cp -R --no-preserve=mode,ownership ${libcava.src} subprojects/cava-0.10.1
      patchShebangs .
      popd
    '';
  } );
}
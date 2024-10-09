
{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, libsecret
, libgcrypt
, openssl
, openvpn
, tun2socks
# , cloak # not the same one
# only packaged on AUR https://github.com/amnezia-vpn/amnezia-client/issues/120
# usage of prebuilt binaries!
, shadowsocks-libev
# , wireguard-go # not the same one
, xray
, qt6
, libsForQt5
, breakpointHook
}:

stdenv.mkDerivation rec {
  pname = "amnezia-client";
  version = "4.8.1.9";
  
  src = fetchFromGitHub {
    repo = "${pname}";
    owner = "amnezia-vpn";

    rev = "${version}";
    sha256 = "IrCdnH9ddROleruqLPcJu5/Pbjxbsb5T9V/KGHkpiJE=";
    fetchSubmodules = true;
  };
  
  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
    pkg-config
    breakpointHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtremoteobjects
    qt6.qtsvg
    qt6.qttools
    qt6.qt5compat
    libsForQt5.qtkeychain
    libsecret
    libgcrypt
    openssl
    openvpn
    tun2socks
#    cloak # not the same one
    shadowsocks-libev
#    wireguard-go # not the same one
    xray
  ];

  installPhase = ''
  runHook preInstall
  make install
  mkdir $out/bin
  mkdir -p $out/share/{pixmaps,applications}
  mkdir -p $out/share/systemd/system/
  cp client/AmneziaVPN $out/bin/
  cp service/server/AmneziaVPN-service $out/bin/
  cp ../deploy/data/linux/client/bin/update-resolv-conf.sh $out/bin/
  cp ../deploy/data/linux/AmneziaVPN.png $out/share/pixmaps/
  cp ../deploy/data/linux/AmneziaVPN.service $out/share/systemd/system/
  cp ../deploy/data/deploy-prebuilt/linux/client/bin/ck-client $out/bin/
  cp ../deploy/data/deploy-prebuilt/linux/client/bin/geoip.dat $out/bin/
  cp ../deploy/data/deploy-prebuilt/linux/client/bin/geosite.dat $out/bin/
  cp ../deploy/data/deploy-prebuilt/linux/client/bin/wireguard-go $out/bin/
  cp ../AppDir/AmneziaVPN.desktop $out/share/applications/
  runHook postInstall
  '';
}
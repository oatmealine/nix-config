{ fetchFromGitHub, fetchurl, lua54Packages, libzip }:
let
  lua-zip = lua54Packages.buildLuarocksPackage {
    pname = "lua-zip";
    version = "0.2-0";
    knownRockspec = (fetchurl {
      url    = "mirror://luarocks/lua-zip-0.2-0.rockspec";
      sha256 = "00116idr7bkv5356gpbciiihl0axwl44cmla6nbk4y1ch4jyha2m";
    }).outPath;
    src = fetchFromGitHub {
      owner = "brimworks";
      repo = "lua-zip";
      rev = "v0.2.0";
      hash = "sha256-pq9gYhLfrA31M9Oz0TJ5Zkno0/U9evnlq80flOyB8qI=";
    };

    externalDeps = [
      { name = "ZIP"; dep = libzip; }
    ];

    meta = {
      homepage = "https://github.com/brimworks/lua-zip";
      description = "Lua binding to libzip";
      license.fullName = "MIT";
    };
  };

  loadconf = lua54Packages.buildLuarocksPackage {
    pname = "loadconf";
    version = "0.3.6-1";
    knownRockspec = (fetchurl {
      url    = "mirror://luarocks/loadconf-0.3.6-1.rockspec";
      sha256 = "0j1ch2hgnjyqpf23dcgv27xps40sxzfk4w1w01cfq7m07cy9ila3";
    }).outPath;
    src = fetchFromGitHub {
      owner = "Alloyed";
      repo = "loadconf";
      rev = "v0.3.6";
      hash = "sha256-1ryXMXlZJss2yxfSYMLf0P9D6Xo1ZvbmzUAnsnXQYJc=";
    };

    meta = {
      homepage = "https://github.com/Alloyed/loadconf";
      description = "No summary";
      license.fullName = "MIT";
    };
  };
in lua54Packages.buildLuarocksPackage {
  pname = "love-release";
  version = "2.0.16-1";
  knownRockspec = (fetchurl {
    url    = "mirror://luarocks/love-release-2.0.16-1.rockspec";
    sha256 = "1nfddi14cglw1d6mh9b2yml7d546jfzpzyfxzbi7yi5yc0m5bh9c";
  }).outPath;
  src = fetchFromGitHub {
    owner = "MisterDA";
    repo = "love-release";
    rev = "v2.0.16";
    hash = "sha256-xUUzkvZ9FU88ndebodXzvLSjWuBZLr7C3N4uSCCGrcY=";
  };

  patches = [
    ./fix-lua-5-4-compat.patch
  ];

  propagatedBuildInputs = with lua54Packages; [ argparse loadconf lua-zip luafilesystem middleclass ];

  meta = {
    homepage = "https://github.com/MisterDA/love-release";
    description = "Make LÖVE games releases easier";
    license.fullName = "MIT";
  };
}
# It doesn't even work out of the box with flakes...
# <https://github.com/nix-community/home-manager/issues/2033#issuecomment-1801557851>
#
# Include this in the `modules` passed to
# `inputs.home-manager.lib.homeManagerConfiguration`.
{ lib, ... }: {
  # disabledModules = [ "misc/news.nix" ];
  config = {
    news.display = "silent";
    news.json = lib.mkForce { };
    news.entries = lib.mkForce [ ];
  };
}
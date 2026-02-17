#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

sudo echo "sudo test OK" || (echo "sudo test FAIL; rerun this outside the FHS env" && exit 1)

[ -f build-hook.sh ] && ./build-hook.sh

#deriv=$(NIXPKGS_ALLOW_UNFREE=1 nix build --no-link --print-out-paths path:.#nixosConfigurations."$(hostname)".config.system.build.toplevel --impure)
#notify-send 'rebuild.sh requires auth'
#sudo nix-env -p /nix/var/nix/profiles/system --set $deriv
#sudo $deriv/bin/switch-to-configuration switch

NIXPKGS_ALLOW_UNFREE=1 nh os switch . -- --impure -v --show-trace

#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
deriv=$(NIXPKGS_ALLOW_UNFREE=1 nix build --no-link --print-out-paths path:.#nixosConfigurations."$(hostname)".config.system.build.toplevel --impure)
notify-send 'rebuild.sh requires auth'
sudo nix-env -p /nix/var/nix/profiles/system --set $deriv
sudo $deriv/bin/switch-to-configuration switch

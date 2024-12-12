#!/usr/bin/env bash
cd "$(dirname "$0")" || exit
nixos-rebuild build --flake . --impure || exit
sudo result/bin/switch-to-configuration switch

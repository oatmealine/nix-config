#!/usr/bin/env bash

niri msg --json event-stream | while read -r event; do
  if echo "$event" | jq -e '.KeyboardLayoutSwitched' >/dev/null 2>&1; then
    idx=$(echo "$event" | jq -r '.KeyboardLayoutSwitched.idx')
    name=$(niri msg --json keyboard-layouts | jq -r ".names[$idx]")
    notify-send "$name" -i "keyboard-layout" -h string:x-dunst-stack-tag:keyboard-layout -t 1500
  fi
done
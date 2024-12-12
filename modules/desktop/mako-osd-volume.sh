#!/usr/bin/env bash
# simple script to control pulseaudio and notify volume
# Author: Newman Sanchez (https://github.com/newmanls)
# modified by Jade Monoids

set -euo pipefail

step=10

case "${1:-}" in
  up)
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%+" ;;
  down)
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ "${step}%-" ;;
  mute)
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
esac

vol=$((10#$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed 's/[^0-9]//g')))
volume="${vol}%"
is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo "yes" || echo "no")

if [ "${is_muted}" = "yes" ]; then
  volume="Muted"
  icon="audio-volume-muted-symbolic"
elif (( vol == 0 )); then
  icon="audio-volume-muted-symbolic"
elif (( vol <= 30 )); then
  icon="audio-volume-low-symbolic"
elif (( vol <= 70 )); then
  icon="audio-volume-medium-symbolic"
else
  icon="audio-volume-high-symbolic"
fi

notify-send \
  "${volume}" \
  -i "${icon}" \
  -h int:value:"${vol}" \
  -h string:x-dunst-stack-tag:volume

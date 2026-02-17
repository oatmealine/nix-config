#!/usr/bin/env bash

case $1 in
  up)   brightnessctl s +5% ;;
  down) brightnessctl s 5%- ;;
esac

brightness=$(brightnessctl -m | awk -F, '{ print $4 }' | sed 's/.$//')

icon='notification-display-brightness'

notify-send \
  "$brightness%" \
  -i $icon \
  -h int:value:$brightness \
  -h string:x-dunst-stack-tag:brightness
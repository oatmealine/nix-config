#!/usr/bin/env bash

case $1 in
  up)   brightnessctl s +5% ;;
  down) brightnessctl s 5%- ;;
esac

brightness=$(brightnessctl -m | awk -F, '{ print $4 }' | sed 's/.$//')

if [ $brightness -lt 30 ]; then
  icon='display-brightness-low-symbolic'
elif [ $brightness -lt 70 ]; then
  icon='display-brightness-medium-symbolic'
else
  icon='display-brightness-high-symbolic'
fi

notify-send \
  "$brightness%" \
  -i $icon \
  -h int:value:$brightness \
  -h string:x-dunst-stack-tag:brightness
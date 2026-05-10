#!/bin/bash
case "$1" in
  up)   brightnessctl -q s +5% ;;
  down) brightnessctl -q s 5%- ;;
esac
PCT=$(brightnessctl -m | grep -oP '\d+%' | head -1 | tr -d '%')
notify-send -h int:value:$PCT "Brightness" "$PCT%" -h string:x-canonical-private-synchronous:brightness -t 1000

#!/bin/bash
SINK="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
MAX=153

case "$1" in
  up)
    pactl set-sink-volume "$SINK" +5%
    ;;
  down)
    pactl set-sink-volume "$SINK" -5%
    ;;
  mute)
    pactl set-sink-mute "$SINK" toggle
    ;;
esac

CUR=$(pactl get-sink-volume "$SINK" | grep -oP '\d+%' | head -1 | tr -d '%')
if [ "$CUR" -gt "$MAX" ]; then
  pactl set-sink-volume "$SINK" "${MAX}%"
  CUR=$MAX
fi

MUTED=$(pactl get-sink-mute "$SINK" | grep -oP 'yes|no')
NORM=$((CUR * 100 / MAX))

if [ "$MUTED" = "yes" ]; then
  notify-send -h int:value:0 "Volume" "Muted" -h string:x-canonical-private-synchronous:volume -t 1000 &
else
  notify-send -h int:value:$NORM "Volume" "${NORM}%" -h string:x-canonical-private-synchronous:volume -t 1000 &
fi

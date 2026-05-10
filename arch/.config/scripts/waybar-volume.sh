#!/bin/bash
VOL=$(pactl get-sink-volume alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink | grep -oP '\d+%' | head -1 | tr -d '%')
MUTED=$(pactl get-sink-mute alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink | grep -q yes && echo 1 || echo 0)
NORM=$((VOL * 100 / 153))

if [ "$MUTED" -eq 1 ]; then
  echo '{"text": "󰖁", "tooltip": "Volume: Muted", "class": "muted"}'
elif [ "$NORM" -le 33 ]; then
  echo "{\"text\": \"󰕿 ${NORM}%\", \"tooltip\": \"Volume: ${NORM}%\"}"
elif [ "$NORM" -le 66 ]; then
  echo "{\"text\": \"󰖀 ${NORM}%\", \"tooltip\": \"Volume: ${NORM}%\"}"
else
  echo "{\"text\": \"󰕾 ${NORM}%\", \"tooltip\": \"Volume: ${NORM}%\"}"
fi

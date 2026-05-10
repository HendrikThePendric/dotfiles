#!/bin/bash
# Set up EasyEffects audio routing after login

SINK_EE="easyeffects_sink"
SINK_HW="alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink"
SRC_EE="easyeffects_source"

# Wait for EasyEffects to create its sink
for i in $(seq 1 20); do
    pactl list sinks short | grep -q "$SINK_EE" && break
    sleep 0.5
done

# Load speaker correction preset
easyeffects -l "Yoga S940 Speaker Fix"

# Configure sinks
pactl set-sink-volume "$SINK_EE" 100%
pactl set-default-sink "$SINK_EE"
pactl set-sink-volume "$SINK_HW" 130%

# Link EasyEffects output to hardware speaker
sleep 1  # Let PW settle
pw-link "${SRC_EE}:capture_FL" "${SINK_HW}:playback_FL" 2>/dev/null || true
pw-link "${SRC_EE}:capture_FR" "${SINK_HW}:playback_FR" 2>/dev/null || true

# Prevent mic feedback loop
pw-link -d "ee_sie_output_level:output_FL" "${SRC_EE}:input_FL" 2>/dev/null
pw-link -d "ee_sie_output_level:output_FR" "${SRC_EE}:input_FR" 2>/dev/null

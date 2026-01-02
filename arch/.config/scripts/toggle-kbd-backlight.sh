#!/bin/sh
# Toggle keyboard backlight on/off

if [ "$(brightnessctl --device=platform::kbd_backlight get)" -eq 0 ]; then
    brightnessctl --device=platform::kbd_backlight set 1
else
    brightnessctl --device=platform::kbd_backlight set 0
fi

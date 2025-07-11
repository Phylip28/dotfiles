#!/bin/bash

LANG=$(echo -e "English (US)\nEspañol (Latam)" | rofi -dmenu \
  -theme ~/.config/rofi/language-selector.rasi)

if [[ "$LANG" == "English (US)" ]]; then
    setxkbmap us
elif [[ "$LANG" == "Español (Latam)" ]]; then
    setxkbmap latam
fi

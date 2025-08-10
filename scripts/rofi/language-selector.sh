#!/bin/bash

LANG=$(echo -e "English (US)\nSpanish (Latam)" | rofi -dmenu \
  -theme ~/.config/rofi/language-selector.rasi)

if [[ "$LANG" == "English (US)" ]]; then
    setxkbmap us
elif [[ "$LANG" == "Spanish (Latam)" ]]; then
    setxkbmap latam
fi

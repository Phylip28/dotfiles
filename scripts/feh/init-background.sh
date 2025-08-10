#!/bin/bash

# Set last wallpaper used by feh
if [ -f "$HOME/.last-wallpaper" ]; then
    feh --bg-scale "$(cat "$HOME/.last-wallpaper")"
fi

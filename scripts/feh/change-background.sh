#!/bin/bash

WALL_DIR="$HOME/wallpapers"
LIST_FILE="$HOME/.cache/wallpapers_list.txt"
INDEX_FILE="$HOME/.cache/current_wall_index"

# recreate the list if new wallpapers are added
CURRENT_COUNT=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | wc -l)
CACHED_COUNT=$(wc -l < "$LIST_FILE" 2>/dev/null || echo 0)

if [[ "$CURRENT_COUNT" -ne "$CACHED_COUNT" ]]; then
    find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort > "$LIST_FILE"
fi

# total available wallpapers
TOTAL=$(wc -l < "$LIST_FILE")

# create indices if they don't exist
if [[ ! -f "$INDEX_FILE" ]]; then
    echo 0 > "$INDEX_FILE"
fi

# read current index and calculate next one
INDEX=$(cat "$INDEX_FILE")
NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))
WALL=$(sed -n "$((NEXT_INDEX + 1))p" "$LIST_FILE")

# set wallpaper and save state
feh --bg-scale "$WALL"
echo "$NEXT_INDEX" > "$INDEX_FILE"
echo "$WALL" > ~/.last-wallpaper

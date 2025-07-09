#!/bin/bash

WALL_DIR="$HOME/wallpapers"
LIST_FILE="$HOME/.cache/wallpapers_list.txt"
INDEX_FILE="$HOME/.cache/current_wall_index"

# crear nuevamente la lista si se agregan nuevos wallpapers
CURRENT_COUNT=$(find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | wc -l)
CACHED_COUNT=$(wc -l < "$LIST_FILE" 2>/dev/null || echo 0)

if [[ "$CURRENT_COUNT" -ne "$CACHED_COUNT" ]]; then
    find "$WALL_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' \) | sort > "$LIST_FILE"
fi

# total de fondos disponibles
TOTAL=$(wc -l < "$LIST_FILE")

# crear los indices si no existen
if [[ ! -f "$INDEX_FILE" ]]; then
    echo 0 > "$INDEX_FILE"
fi

# leer el indice actual y calcular el siguiente
INDEX=$(cat "$INDEX_FILE")
NEXT_INDEX=$(( (INDEX + 1) % TOTAL ))
FONDO=$(sed -n "$((NEXT_INDEX + 1))p" "$LIST_FILE")

# colocar el fondo y guardar estado
feh --bg-scale "$FONDO"
echo "$NEXT_INDEX" > "$INDEX_FILE"
echo "$FONDO" > ~/.feh_fondo_actual


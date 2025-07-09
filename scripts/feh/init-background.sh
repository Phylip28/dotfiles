#!/bin/bash

# colocar el ultimo fondo usado
if [ -f "$HOME/.feh_fondo_actual" ]; then
    feh --bg-scale "$(cat "$HOME/.feh_fondo_actual")"
fi


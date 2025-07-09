#!/usr/bin/env bash

# Terminate already running bar instances
# polybar-msg cmd quit # Esta es una alternativa más moderna para terminar instancias
killall -q polybar

# Wait until the processes have been purged
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config.ini
# Puedes nombrar tu barra como quieras en ~/.config/polybar/config.ini
# Por ejemplo, si tu barra se llama 'main_bar' en config.ini, pones:
# polybar main_bar &

# Para empezar, usaremos 'example' como en la configuración de ejemplo.
# Si tienes múltiples monitores, puedes usar un bucle.
# Por ahora, un lanzamiento simple:
polybar example &

echo "Polybar launched..."

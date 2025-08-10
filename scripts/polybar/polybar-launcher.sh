#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been purged
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch Polybar, using default config.ini
# You can name your bar whatever you want in ~/.config/polybar/config.ini
# For example, if your bar is called 'main_bar' in config.ini, you put:
# polybar main_bar &

# To start, we'll use 'example' as in the example configuration.
# If you have multiple monitors, you can use a loop.
# For now, a simple launch:
polybar example &

echo "Polybar launched..."

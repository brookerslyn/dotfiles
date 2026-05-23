#!/bin/bash
# Watch waypaper config for wallpaper changes and regenerate colors
while true; do
    inotifywait -qq -e modify,close_write ~/.config/waypaper/config.ini 2>/dev/null
    sleep 0.5
    ~/.config/hypr/scripts/wallpaper-matugen.sh 2>/dev/null
done

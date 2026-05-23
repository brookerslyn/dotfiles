#!/bin/bash
sleep 1
pgrep -f linux-wallpaperengine || waypaper --restore &
sleep 1
pgrep -x quickshell || quickshell -d &
pgrep -f wallpaper-watcher || ~/.config/hypr/scripts/wallpaper-watcher.sh &
pgrep -x easyeffects || easyeffects --gapplication-service &
# Clipboard history daemon
pgrep -f "wl-paste.*cliphist" || (
    wl-paste --type text --watch cliphist store &
    wl-paste --type image --watch cliphist store &
)

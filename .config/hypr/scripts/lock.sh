#!/usr/bin/env bash
source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "lock"

# Pick random wallpaper for lock screen background
IMG=$(find ~/Pictures/wallpapers -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n1)
[ -n "$IMG" ] && cp "$IMG" "$QS_CACHE_LOCK/lock_wallpaper.png"

quickshell -p ~/.config/hypr/scripts/quickshell/Lock.qml

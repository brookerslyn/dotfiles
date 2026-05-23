#!/bin/bash
mkdir -p ~/.cache/rofi
IMG=$(find ~/Pictures/wallpapers -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) | shuf -n1)
[ -n "$IMG" ] && rm -f ~/.cache/rofi/random_wallpaper.png && cp "$IMG" ~/.cache/rofi/random_wallpaper.png
rofi -show drun

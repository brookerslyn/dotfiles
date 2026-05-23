#!/bin/bash
# Kitty startup script - show a random wallpaper as logo, then start shell
WALLPAPERS=(~/Pictures/wallpapers/*.{jpg,png})
RANDOM_WALL="${WALLPAPERS[RANDOM % ${#WALLPAPERS[@]}]}"

# Display centered, faded image
kitty +kitten icat --align center --place 40x20@center "$RANDOM_WALL" 2>/dev/null

exec $SHELL

#!/bin/bash
WALLPAPER="${1:-$(grep '^wallpaper =' ~/.config/waypaper/config.ini 2>/dev/null | head -1 | cut -d= -f2 | tr -d ' ' | sed "s|~|$HOME|")}"

[ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ] && exit 1

FRAME="/tmp/wallpaper_frame.png"

if file "$WALLPAPER" | grep -qiE "gif|video|matroska|mp4|webm"; then
    ffmpeg -y -i "$WALLPAPER" -vframes 1 -ss 00:00:01 "$FRAME" 2>/dev/null || \
    ffmpeg -y -i "$WALLPAPER" -vframes 1 "$FRAME" 2>/dev/null
else
    cp "$WALLPAPER" "$FRAME"
fi

[ ! -f "$FRAME" ] && exit 1

matugen image --prefer darkness "$FRAME"
cp "$FRAME" "$HOME/.config/hypr/current_wallpaper_frame.png"
rm -f "$FRAME"

#!/bin/bash
# Toggle clipboard widget
if pgrep -f "quickshell.*Clipboard.qml" > /dev/null; then
    pkill -f "quickshell.*Clipboard.qml"
else
    quickshell -p ~/.config/hypr/scripts/quickshell/Clipboard.qml &
fi

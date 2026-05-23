#!/bin/bash
if pgrep -f "quickshell.*Sidebar.qml" > /dev/null; then
    pkill -f "quickshell.*Sidebar.qml"
else
    quickshell -p ~/.config/hypr/scripts/quickshell/Sidebar.qml &
fi

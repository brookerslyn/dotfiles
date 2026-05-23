import QtQuick

Item {
    id: root
    visible: false

    property real currentWidth: 1920.0
    property real currentHeight: 1080.0
    property real uiScale: 1.0

    property real baseScale: (currentWidth / 1920.0) * uiScale

    function s(val) {
        return Math.round(val * baseScale);
    }
}

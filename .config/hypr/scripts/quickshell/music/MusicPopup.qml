import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root

    Scaler { id: scaler; currentWidth: Screen.width }
    function s(val) { return scaler.s(val) }

    MatugenColors { id: theme }

    property var musicData: ({})

    // Card
    Rectangle {
        anchors.fill: parent
        radius: s(16)
        color: Qt.rgba(theme.base.r, theme.base.g, theme.base.b, 0.55)
        border.width: 1
        border.color: Qt.rgba(theme.text.r, theme.text.g, theme.text.b, 0.06)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: s(16)
            spacing: s(12)

            // Top row: art + title
            RowLayout {
                Layout.fillWidth: true
                spacing: s(12)

                Rectangle {
                    Layout.preferredWidth: s(80)
                    Layout.preferredHeight: s(80)
                    radius: s(10)
                    color: Qt.rgba(theme.surface0.r, theme.surface0.g, theme.surface0.b, 0.5)
                    clip: true

                    Image {
                        id: art
                        anchors.fill: parent
                        source: musicData.artUrl || ""
                        fillMode: Image.PreserveAspectCrop
                        visible: source != ""
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "♪"
                        color: theme.blue
                        font.pixelSize: s(32)
                        visible: !art.visible
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: s(2)

                    Text {
                        Layout.fillWidth: true
                        text: musicData.title || "Nothing playing"
                        color: theme.text
                        font.pixelSize: s(15)
                        font.bold: true
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: musicData.artist || ""
                        color: theme.subtext0
                        font.pixelSize: s(12)
                        elide: Text.ElideRight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: musicData.album || ""
                        color: theme.subtext0
                        font.pixelSize: s(10)
                        opacity: 0.7
                        elide: Text.ElideRight
                    }
                }
            }

            // Progress bar
            ColumnLayout {
                Layout.fillWidth: true
                spacing: s(4)

                Rectangle {
                    Layout.fillWidth: true
                    height: s(4)
                    radius: s(2)
                    color: Qt.rgba(theme.subtext0.r, theme.subtext0.g, theme.subtext0.b, 0.2)

                    Rectangle {
                        height: parent.height
                        radius: s(2)
                        color: theme.blue
                        width: parent.width * (musicData.progress || 0)
                        Behavior on width { NumberAnimation { duration: 200 } }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: musicData.posStr || "0:00"; color: theme.subtext0; font.pixelSize: s(10) }
                    Item { Layout.fillWidth: true }
                    Text { text: musicData.lenStr || "0:00"; color: theme.subtext0; font.pixelSize: s(10) }
                }
            }

            // Controls
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: s(20)

                Repeater {
                    model: [
                        { icon: "󰒮", cmd: "previous", size: 22 },
                        { icon: musicData.status === "Playing" ? "󰏤" : "󰐊", cmd: "play-pause", size: 28 },
                        { icon: "󰒭", cmd: "next", size: 22 }
                    ]
                    delegate: Text {
                        text: modelData.icon
                        color: ma.containsMouse ? theme.blue : theme.text
                        font.pixelSize: s(modelData.size)
                        Behavior on color { ColorAnimation { duration: 120 } }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached(["playerctl", modelData.cmd])
                        }
                    }
                }
            }
        }
    }

    // Music data poller
    Process {
        id: mFetch
        command: ["bash", "-c", "playerctl metadata --format '{{title}}|{{artist}}|{{album}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}' 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let parts = this.text.trim().split("|")
                if (parts.length < 7) { return }
                let pos = parseInt(parts[5]) || 0
                let len = parseInt(parts[6]) || 1
                let progress = len > 0 ? Math.min(1.0, pos / len) : 0

                function fmt(us) {
                    let s = Math.floor(us / 1000000)
                    let m = Math.floor(s / 60)
                    let sec = s % 60
                    return m + ":" + (sec < 10 ? "0" : "") + sec
                }

                let url = parts[3] || ""
                if (url.startsWith("file://")) url = url
                musicData = {
                    title: parts[0] || "",
                    artist: parts[1] || "",
                    album: parts[2] || "",
                    artUrl: url,
                    status: parts[4] || "Stopped",
                    posStr: fmt(pos),
                    lenStr: fmt(len),
                    progress: progress
                }
            }
        }
    }
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { mFetch.running = false; mFetch.running = true } }
}

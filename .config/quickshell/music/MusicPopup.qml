import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../"

Item {
    id: root

    MatugenColors { id: mocha }

    property var musicData: { "title": "", "artist": "", "status": "Stopped", "percent": 0, "positionStr": "00:00", "lengthStr": "00:00", "artUrl": "", "playerName": "" }

    Process {
        id: musicProc
        command: ["bash", "-c", "$HOME/.config/hypr/scripts/quickshell/music/music_info.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (this.text) {
                    try { root.musicData = JSON.parse(this.text.trim()); } catch(e) {}
                }
            }
        }
    }
    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { musicProc.running = false; musicProc.running = true } }

    function cmd(c) { Quickshell.execDetached(["bash", "-c", c]) }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 8
        radius: 16
        color: Qt.rgba(mocha.base.r, mocha.base.g, mocha.base.b, 0.92)
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            // Album art + info
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Rectangle {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64
                    radius: 10; color: mocha.surface0; clip: true
                    Image {
                        anchors.fill: parent
                        source: root.musicData.artUrl ? "file://" + root.musicData.artUrl : ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }
                    Text { anchors.centerIn: parent; text: "󰎈"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 24; color: mocha.overlay0; visible: !root.musicData.artUrl }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { text: root.musicData.title || "Nothing playing"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 13; font.weight: Font.Black; color: mocha.text; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: root.musicData.artist || ""; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 11; color: mocha.overlay1; Layout.fillWidth: true; elide: Text.ElideRight }
                }
            }

            // Progress
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Text { text: root.musicData.positionStr || "00:00"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 10; color: mocha.overlay1 }
                Rectangle {
                    Layout.fillWidth: true; height: 4; radius: 2; color: mocha.surface1
                    Rectangle { width: parent.width * (root.musicData.percent || 0) / 100; height: parent.height; radius: 2; color: mocha.mauve; Behavior on width { NumberAnimation { duration: 500 } } }
                }
                Text { text: root.musicData.lengthStr || "00:00"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 10; color: mocha.overlay1 }
            }

            // Controls
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20
                Text { text: "󰒟"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 16; color: mocha.overlay1; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.cmd("playerctl --ignore-player=firefox,chromium shuffle Toggle") } }
                Text { text: "󰒮"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 18; color: mocha.overlay2; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.cmd("playerctl --ignore-player=firefox,chromium previous") } }
                Text { text: root.musicData.status === "Playing" ? "󰏤" : "󰐊"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 26; color: mocha.mauve; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.cmd("playerctl --ignore-player=firefox,chromium play-pause") } }
                Text { text: "󰒭"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 18; color: mocha.overlay2; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.cmd("playerctl --ignore-player=firefox,chromium next") } }
                Text { text: "󰑖"; font.family: "JetBrainsMono Nerd Font Propo"; font.pixelSize: 16; color: mocha.overlay1; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.cmd("playerctl --ignore-player=firefox,chromium loop Track") } }
            }
        }
    }
}

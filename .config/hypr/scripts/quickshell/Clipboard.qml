import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../"

ShellRoot {
    id: root
    MatugenColors { id: t }

    property int cursorX: 0
    property int cursorY: 0
    property bool positionsLoaded: false

    Process {
        id: cursorFetch
        command: ["bash", "-c", "hyprctl cursorpos -j 2>/dev/null | jq -r '.x, .y'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n")
                root.cursorX = parseInt(lines[0]) || 0
                root.cursorY = parseInt(lines[1]) || 0
                root.positionsLoaded = true
            }
        }
    }

    // Pre-extract all image clips on startup
    Process {
        id: imageExtract
        command: ["bash", "-c", "mkdir -p /tmp/cliphist-thumbs && cliphist list | while IFS=$'\\t' read -r id rest; do if echo \"$rest\" | grep -q '\\[\\[ binary'; then cliphist decode $id > \"/tmp/cliphist-thumbs/$id.bin\" 2>/dev/null; fi; done"]
        running: true
    }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: panel
                required property var modelData
                screen: modelData
                visible: root.positionsLoaded
                WlrLayershell.namespace: "quickshell"
                WlrLayershell.layer: WlrLayer.Overlay
                WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                focusable: true
                anchors { top: true; bottom: true; left: true; right: true }

                property color bg: Qt.rgba(t.base.r, t.base.g, t.base.b, 0.85)
                property color card: Qt.rgba(t.surface0.r, t.surface0.g, t.surface0.b, 0.5)
                property color hover: Qt.rgba(t.text.r, t.text.g, t.text.b, 0.08)
                property color txt: t.text
                property color sub: t.subtext0
                property color acc: t.blue

                // Click outside to close
                MouseArea {
                    anchors.fill: parent
                    onPressed: function(mouse) {
                        // Check if click is outside popup
                        let popupGlobalX = popup.x
                        let popupGlobalY = popup.y
                        if (mouse.x < popupGlobalX || mouse.x > popupGlobalX + popup.width ||
                            mouse.y < popupGlobalY || mouse.y > popupGlobalY + popup.height) {
                            Qt.quit()
                        } else {
                            mouse.accepted = false
                        }
                    }
                }

                Rectangle {
                    id: popup
                    width: 380
                    height: 460

                    x: Math.min(Math.max(root.cursorX - 50, 10), screen.width - width - 10)
                    y: Math.min(Math.max(root.cursorY + 20, 10), screen.height - height - 10)

                    radius: 12
                    color: panel.bg
                    border.width: 1
                    border.color: Qt.rgba(panel.txt.r, panel.txt.g, panel.txt.b, 0.08)

                    transform: Translate { id: slide; y: 10 }
                    opacity: 0
                    Component.onCompleted: { slide.y = 0; opacity = 1 }
                    Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        // Header
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "󰅍"; color: panel.acc; font.pixelSize: 14 }
                            Text { text: "Clipboard"; color: panel.txt; font.pixelSize: 13; font.bold: true; Layout.fillWidth: true }
                            Text {
                                text: "Clear"
                                color: clrMa.containsMouse ? panel.acc : panel.sub
                                font.pixelSize: 10
                                Behavior on color { ColorAnimation { duration: 120 } }
                                MouseArea {
                                    id: clrMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { Quickshell.execDetached(["cliphist", "wipe"]); model.clear(); filteredModel.clear() }
                                }
                            }
                        }

                        // Search
                        Rectangle {
                            Layout.fillWidth: true; height: 32
                            radius: 8
                            color: panel.card
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10; anchors.rightMargin: 10
                                spacing: 6
                                Text { text: "󰍉"; color: panel.sub; font.pixelSize: 12 }
                                TextInput {
                                    id: searchInput
                                    Layout.fillWidth: true
                                    color: panel.txt
                                    font.pixelSize: 12
                                    selectByMouse: true
                                    focus: true
                                    Keys.onEscapePressed: Qt.quit()
                                }
                                Text {
                                    text: "search..."
                                    color: panel.sub
                                    font.pixelSize: 12
                                    visible: searchInput.text === ""
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left: parent.left
                                    anchors.leftMargin: 24
                                }
                            }
                        }

                        // List
                        ListView {
                            id: clipList
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            spacing: 4
                            model: filteredModel

                            function refilter() {
                                let q = searchInput.text.toLowerCase()
                                filteredModel.clear()
                                for (let i = 0; i < model.count; i++) {
                                    let item = model.get(i)
                                    if (q === "" || (item.preview || "").toLowerCase().includes(q)) {
                                        filteredModel.append(item)
                                    }
                                }
                            }

                            Connections {
                                target: searchInput
                                function onTextChanged() { clipList.refilter() }
                            }

                            delegate: Rectangle {
                                width: ListView.view.width
                                height: model.isImage ? 80 : 50
                                radius: 8
                                color: itemMa.containsMouse ? panel.hover : "transparent"
                                Behavior on color { ColorAnimation { duration: 100 } }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 8; anchors.rightMargin: 8
                                    spacing: 10

                                    // Image thumbnail OR text icon
                                    Item {
                                        Layout.preferredWidth: model.isImage ? 64 : 24
                                        Layout.preferredHeight: model.isImage ? 64 : 24

                                        Image {
                                            anchors.fill: parent
                                            source: model.isImage ? "file:///tmp/cliphist-thumbs/" + model.id + ".bin" : ""
                                            fillMode: Image.PreserveAspectCrop
                                            visible: model.isImage
                                            asynchronous: true
                                            sourceSize.width: 128
                                            sourceSize.height: 128
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰈙"
                                            color: panel.acc
                                            font.pixelSize: 16
                                            visible: !model.isImage
                                        }
                                    }

                                    Text {
                                        text: model.preview || ""
                                        color: panel.txt
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        maximumLineCount: model.isImage ? 1 : 2
                                        wrapMode: Text.Wrap
                                    }

                                    Text {
                                        text: "󰅖"
                                        color: delMa.containsMouse ? t.red : panel.sub
                                        font.pixelSize: 14
                                        opacity: itemMa.containsMouse ? 1 : 0
                                        Behavior on opacity { NumberAnimation { duration: 100 } }
                                        MouseArea {
                                            id: delMa
                                            anchors.fill: parent
                                            anchors.margins: -4
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Quickshell.execDetached(["bash", "-c", "echo '" + (model.line || "").replace(/'/g, "'\\''") + "' | cliphist delete"])
                                                refreshTimer.start()
                                            }
                                        }
                                    }
                                }

                                MouseArea {
                                    id: itemMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached(["bash", "-c", "echo '" + (model.line || "").replace(/'/g, "'\\''") + "' | cliphist decode | wl-copy"])
                                        Qt.quit()
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "Clipboard is empty"
                                color: panel.sub
                                font.pixelSize: 12
                                visible: filteredModel.count === 0
                            }
                        }
                    }

                    ListModel { id: model }
                    ListModel { id: filteredModel }

                    Process {
                        id: clipFetch
                        command: ["cliphist", "list"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                let lines = this.text.split("\n").filter(l => l.trim() !== "")
                                model.clear()
                                for (let line of lines.slice(0, 50)) {
                                    let parts = line.split("\t")
                                    if (parts.length < 2) continue
                                    let id = parts[0]
                                    let preview = parts.slice(1).join("\t")
                                    let isImage = preview.includes("[[ binary") || preview.includes("image/")
                                    model.append({
                                        id: id,
                                        line: line,
                                        preview: isImage ? preview.replace(/\[\[\s*binary[^\]]*\]\]/, "Image").substring(0, 80) : preview.substring(0, 200),
                                        isImage: isImage
                                    })
                                }
                                clipList.refilter()
                            }
                        }
                    }

                    Timer {
                        id: refreshTimer
                        interval: 100
                        onTriggered: { clipFetch.running = false; clipFetch.running = true }
                    }
                }
            }
        }
    }
}

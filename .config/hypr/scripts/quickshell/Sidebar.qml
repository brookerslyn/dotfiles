import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../"

ShellRoot {
    id: root
    MatugenColors { id: t }

    Variants {
        model: Quickshell.screens
        delegate: Component {
            PanelWindow {
                id: panel
                required property var modelData
                screen: modelData
                WlrLayershell.namespace: "quickshell"
                WlrLayershell.layer: WlrLayer.Overlay
                exclusionMode: ExclusionMode.Ignore
                color: "transparent"
                focusable: true
                anchors { top: true; bottom: true; right: true }
                implicitWidth: 380
                margins { top: 50; bottom: 10; right: 10 }

                property color bg: Qt.rgba(t.base.r, t.base.g, t.base.b, 0.55)
                property color card: Qt.rgba(t.text.r, t.text.g, t.text.b, 0.04)
                property color txt: t.text
                property color sub: t.subtext0
                property color acc: t.blue
                property color acc2: t.sapphire
                property var musicData: ({title:"", artist:"", art:"", status:"Stopped", posStr:"0:00", lenStr:"0:00", progress:0})

                HyprlandFocusGrab {
                    id: grab
                    windows: [panel]
                    active: true
                    onCleared: Qt.quit()
                }

                // Animated entry handled by inner rectangle

                Rectangle {
                    anchors.fill: parent
                    radius: 14
                    color: panel.bg
                    Flickable {
                        anchors.fill: parent
                        anchors.margins: 16
                        contentHeight: mainCol.height
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        Column {
                            id: mainCol
                            width: parent.width
                            spacing: 12

                            // user + system stats header
                            Rectangle {
                                width: parent.width; height: 80; radius: 12; color: panel.card
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 10

                                    // Avatar
                                    Rectangle {
                                        Layout.preferredWidth: 48; Layout.preferredHeight: 48
                                        radius: 24; color: panel.acc
                                        Text { anchors.centerIn: parent; text: "󰀄"; color: panel.bg; font.pixelSize: 24 }
                                    }
                                    // Name + uptime
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2
                                        Text { text: Quickshell.env("USER") || "user"; color: panel.txt; font.pixelSize: 15; font.bold: true; elide: Text.ElideRight; Layout.fillWidth: true }
                                        Text { id: upTxt; text: ""; color: panel.sub; font.pixelSize: 9; elide: Text.ElideRight; Layout.fillWidth: true }
                                    }
                                    // Stats stack (right-aligned, fixed width)
                                    ColumnLayout {
                                        Layout.preferredWidth: 75
                                        spacing: 3
                                        RowLayout { spacing: 4; Text { text: "󰍛"; color: panel.acc; font.pixelSize: 10 } Text { text: "CPU"; color: panel.sub; font.pixelSize: 8; Layout.fillWidth: true } Text { id: cpuTxt; text: "0%"; color: panel.txt; font.pixelSize: 10 } }
                                        RowLayout { spacing: 4; Text { text: "󰘚"; color: panel.acc; font.pixelSize: 10 } Text { text: "RAM"; color: panel.sub; font.pixelSize: 8; Layout.fillWidth: true } Text { id: ramTxt; text: "0%"; color: panel.txt; font.pixelSize: 10 } }
                                        RowLayout { spacing: 4; Text { text: "󰋊"; color: panel.acc; font.pixelSize: 10 } Text { text: "DSK"; color: panel.sub; font.pixelSize: 8; Layout.fillWidth: true } Text { id: dskTxt; text: "0%"; color: panel.txt; font.pixelSize: 10 } }
                                    }
                                }
                            }

                            // music player
                            Rectangle {
                                width: parent.width; height: 130; radius: 12; color: panel.card
                                clip: true

                                // Background art (blurred via low opacity)
                                Image {
                                    id: artBg
                                    anchors.fill: parent
                                    source: panel.musicData.art || ""
                                    fillMode: Image.PreserveAspectCrop
                                    opacity: 0.15
                                    visible: source != ""
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(panel.card.r, panel.card.g, panel.card.b, 0.4)
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 12

                                    // Album art
                                    Rectangle {
                                        width: 90; height: 90; radius: 12
                                        color: Qt.rgba(panel.acc.r, panel.acc.g, panel.acc.b, 0.12)
                                        anchors.verticalCenter: parent.verticalCenter
                                        clip: true
                                        Image { anchors.fill: parent; source: panel.musicData.art || ""; fillMode: Image.PreserveAspectCrop }
                                        Text { anchors.centerIn: parent; text: "♪"; color: panel.acc; font.pixelSize: 32; visible: !panel.musicData.art }
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: parent.width - 110
                                        spacing: 6

                                        Text { text: panel.musicData.title || "Nothing playing"; color: panel.txt; font.pixelSize: 14; font.bold: true; elide: Text.ElideRight; width: parent.width }
                                        Text { text: panel.musicData.artist || ""; color: panel.sub; font.pixelSize: 11; elide: Text.ElideRight; width: parent.width }

                                        // Progress
                                        Rectangle {
                                            width: parent.width; height: 4; radius: 2
                                            color: Qt.rgba(panel.sub.r, panel.sub.g, panel.sub.b, 0.2)
                                            Rectangle {
                                                height: parent.height; radius: 2; color: panel.acc
                                                width: parent.width * (panel.musicData.progress || 0)
                                                Behavior on width { NumberAnimation { duration: 300 } }
                                            }
                                        }

                                        Row {
                                            width: parent.width
                                            Text { text: panel.musicData.posStr || "0:00"; color: panel.sub; font.pixelSize: 9 }
                                            Item { width: parent.width - 80; height: 1 }
                                            Text { text: panel.musicData.lenStr || "0:00"; color: panel.sub; font.pixelSize: 9 }
                                        }

                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            spacing: 18
                                            Repeater {
                                                model: [
                                                    { i: "󰒮", c: "previous" },
                                                    { i: panel.musicData.status === "Playing" ? "󰏤" : "󰐊", c: "play-pause" },
                                                    { i: "󰒭", c: "next" }
                                                ]
                                                delegate: Text {
                                                    text: modelData.i
                                                    color: ma.containsMouse ? panel.acc : panel.txt
                                                    font.pixelSize: 18
                                                    Behavior on color { ColorAnimation { duration: 100 } }
                                                    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["playerctl", modelData.c]) }
                                                }
                                            }
                                        }
                                    }
                                }

                                Process {
                                    id: mFetch
                                    command: ["bash", "-c", "p=$(playerctl --ignore-player=firefox,chromium,org.webkit.app -l 2>/dev/null | head -1); [ -z \"$p\" ] && echo '||||||' && exit; playerctl -p \"$p\" metadata --format '{{title}}|{{artist}}|{{mpris:artUrl}}|{{status}}|{{position}}|{{mpris:length}}' 2>/dev/null"]
                                    running: true
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            let p = this.text.trim().split("|")
                                            if (p.length < 6) return
                                            let pos = parseInt(p[4]) || 0
                                            let len = parseInt(p[5]) || 1
                                            function fmt(us) {
                                                let s = Math.floor(us / 1000000)
                                                return Math.floor(s/60) + ":" + (s%60 < 10 ? "0" : "") + (s%60)
                                            }
                                            panel.musicData = {
                                                title: p[0] || "",
                                                artist: p[1] || "",
                                                art: p[2] && p[2].startsWith("file://") ? p[2] : (p[2] || ""),
                                                status: p[3] || "Stopped",
                                                posStr: fmt(pos),
                                                lenStr: fmt(len),
                                                progress: len > 0 ? pos/len : 0
                                            }
                                        }
                                    }
                                }
                                Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { mFetch.running = false; mFetch.running = true } }
                            }

                            // volume + brightness sliders
                            Row {
                                width: parent.width
                                spacing: 8

                                Rectangle {
                                    width: (parent.width - 8) / 2; height: 64; radius: 10; color: panel.card
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6
                                        Row {
                                            spacing: 6
                                            Text { text: "󰕾"; color: panel.acc; font.pixelSize: 13 }
                                            Text { text: "Volume"; color: panel.sub; font.pixelSize: 10 }
                                            Item { width: 30; height: 1 }
                                            Text { id: vLbl; text: "0%"; color: panel.txt; font.pixelSize: 10 }
                                        }
                                        Rectangle {
                                            width: parent.width; height: 6; radius: 3
                                            color: Qt.rgba(panel.sub.r, panel.sub.g, panel.sub.b, 0.2)
                                            Rectangle { height: parent.height; radius: 3; color: panel.acc; width: parent.width * vObj.val / 100; Behavior on width { NumberAnimation { duration: 80 } } }
                                            QtObject { id: vObj; property int val: 0 }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onPressed: (m) => setV(m); onPositionChanged: (m) => { if (pressed) setV(m) }
                                                function setV(m) { let v = Math.max(0, Math.min(100, Math.round(m.x/parent.width*100))); vObj.val=v; vLbl.text=v+"%"; Quickshell.execDetached(["wpctl","set-volume","@DEFAULT_AUDIO_SINK@",(v/100).toFixed(2)]) }
                                            }
                                            Process { id: vF; command:["bash","-c","wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'"]; running:true; stdout: StdioCollector { onStreamFinished: { vObj.val=parseInt(this.text.trim())||0; vLbl.text=vObj.val+"%" } } }
                                            Timer { interval: 2000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { vF.running=false; vF.running=true } }
                                        }
                                    }
                                }
                                Rectangle {
                                    width: (parent.width - 8) / 2; height: 64; radius: 10; color: panel.card
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 6
                                        Row {
                                            spacing: 6
                                            Text { text: "󰃟"; color: panel.acc2; font.pixelSize: 13 }
                                            Text { text: "Bright"; color: panel.sub; font.pixelSize: 10 }
                                            Item { width: 36; height: 1 }
                                            Text { id: bLbl; text: "100%"; color: panel.txt; font.pixelSize: 10 }
                                        }
                                        Rectangle {
                                            width: parent.width; height: 6; radius: 3
                                            color: Qt.rgba(panel.sub.r, panel.sub.g, panel.sub.b, 0.2)
                                            Rectangle { height: parent.height; radius: 3; color: panel.acc2; width: parent.width * bObj.val / 100; Behavior on width { NumberAnimation { duration: 80 } } }
                                            QtObject { id: bObj; property int val: 100 }
                                            MouseArea {
                                                anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                                onPressed: (m) => setB(m); onPositionChanged: (m) => { if (pressed) setB(m) }
                                                function setB(m) { let v = Math.max(1, Math.min(100, Math.round(m.x/parent.width*100))); bObj.val=v; bLbl.text=v+"%"; Quickshell.execDetached(["brightnessctl","set",v+"%"]) }
                                            }
                                            Process { id: bF; command:["bash","-c","brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%' || echo 100"]; running:true; stdout: StdioCollector { onStreamFinished: { bObj.val=parseInt(this.text.trim())||100; bLbl.text=bObj.val+"%" } } }
                                            Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { bF.running=false; bF.running=true } }
                                        }
                                    }
                                }
                            }

                            // quick toggles grid
                            Grid {
                                width: parent.width
                                columns: 4
                                spacing: 8

                                Repeater {
                                    model: [
                                        { icon: "󰕾", label: "Mute", cmd: "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" },
                                        { icon: "󰂚", label: "DND", toggle: true, on: "swaync-client -d", off: "swaync-client -df" },
                                        { icon: "󰚭", label: "Color", cmd: "hyprpicker -a" },
                                        { icon: "󰹑", label: "Shot", cmd: "grim -g \"$(slurp)\" - | wl-copy" },
                                        { icon: "󰸉", label: "Wall", cmd: "waypaper" },
                                        { icon: "󰒓", label: "Term", cmd: "kitty" },
                                        { icon: "󰦛", label: "Reload", cmd: "hyprctl reload" },
                                        { icon: "󰐥", label: "Power", cmd: "wlogout" }
                                    ]
                                    delegate: Rectangle {
                                        width: (mainCol.width - 24) / 4; height: 60; radius: 14
                                        property bool isOn: false
                                        color: tMa.containsMouse ? Qt.rgba(panel.acc.r, panel.acc.g, panel.acc.b, 0.2) : (isOn ? Qt.rgba(panel.acc.r, panel.acc.g, panel.acc.b, 0.15) : panel.card)
                                        Behavior on color { ColorAnimation { duration: 120 } }
                                        Column {
                                            anchors.centerIn: parent; spacing: 3
                                            Text { text: modelData.icon; color: panel.acc; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter }
                                            Text { text: modelData.label; color: panel.sub; font.pixelSize: 9; anchors.horizontalCenter: parent.horizontalCenter }
                                        }
                                        MouseArea {
                                            id: tMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData.toggle) {
                                                    parent.isOn = !parent.isOn
                                                    Quickshell.execDetached(["bash", "-c", parent.isOn ? modelData.on : modelData.off])
                                                } else if (modelData.cmd) {
                                                    Quickshell.execDetached(["bash", "-c", modelData.cmd])
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // record button
                            Rectangle {
                                id: recBtn
                                width: parent.width; height: 50; radius: 14
                                property bool recording: false
                                color: recording ? Qt.rgba(t.red.r, t.red.g, t.red.b, 0.25) : panel.card
                                Behavior on color { ColorAnimation { duration: 150 } }
                                Row {
                                    anchors.centerIn: parent; spacing: 10
                                    Rectangle {
                                        width: 12; height: 12; radius: 6; color: recBtn.recording ? t.red : panel.sub; anchors.verticalCenter: parent.verticalCenter
                                        SequentialAnimation on opacity { running: recBtn.recording; loops: Animation.Infinite; NumberAnimation { to: 0.3; duration: 600 }
                                            NumberAnimation { to: 1.0; duration: 600 } }
                                    }
                                    Text { text: recBtn.recording ? "Stop Recording" : "Start Screen Recording"; color: recBtn.recording ? t.red : panel.txt; font.pixelSize: 13 }
                                }
                                MouseArea {
                                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        recBtn.recording = !recBtn.recording
                                        if (recBtn.recording)
                                            Quickshell.execDetached(["bash", "-c", "gpu-screen-recorder -w screen -f 60 -o ~/Videos/rec_$(date +%s).mp4 &"])
                                        else
                                            Quickshell.execDetached(["pkill", "-SIGINT", "gpu-screen-rec"])
                                    }
                                }
                            }

                            // notifications
                            Rectangle {
                                width: parent.width
                                height: Math.min(220, nList.contentHeight + 50)
                                radius: 12
                                color: panel.card

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 14
                                    spacing: 8

                                    Row {
                                        width: parent.width
                                        Text { text: "󰂚 Notifications"; color: panel.txt; font.pixelSize: 12; font.bold: true; anchors.verticalCenter: parent.verticalCenter }
                                        Item { width: parent.width - 180; height: 1 }
                                        Text {
                                            text: "Clear all"
                                            color: clrMa.containsMouse ? panel.acc : panel.sub
                                            font.pixelSize: 10
                                            Behavior on color { ColorAnimation { duration: 120 } }
                                            MouseArea { id: clrMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Quickshell.execDetached(["swaync-client", "-C"]) }
                                        }
                                    }

                                    ListView {
                                        id: nList
                                        width: parent.width
                                        height: parent.height - 30
                                        clip: true
                                        spacing: 6
                                        model: nModel

                                        delegate: Rectangle {
                                            width: ListView.view.width
                                            height: nC.height + 14
                                            radius: 10
                                            color: Qt.rgba(panel.bg.r, panel.bg.g, panel.bg.b, 0.5)

                                            Column {
                                                id: nC
                                                anchors { left: parent.left; right: parent.right; top: parent.top; margins: 7 }
                                                spacing: 2
                                                Text { text: model.app; color: panel.acc; font.pixelSize: 9; font.bold: true }
                                                Text { text: model.body; color: panel.txt; font.pixelSize: 11; wrapMode: Text.Wrap; width: parent.width }
                                            }
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            text: "No new notifications"
                                            color: panel.sub
                                            font.pixelSize: 11
                                            visible: nModel.count === 0
                                        }
                                    }
                                }

                                ListModel { id: nModel }
                                Process {
                                    id: nF
                                    command: ["bash", "-c", "swaync-client -G 2>/dev/null | jq -c '[.[] | {app: .app_name, body: .body.data}]' 2>/dev/null || echo '[]'"]
                                    running: true
                                    stdout: StdioCollector {
                                        onStreamFinished: {
                                            try {
                                                let items = JSON.parse(this.text.trim())
                                                nModel.clear()
                                                for (let i = 0; i < Math.min(items.length, 15); i++)
                                                    nModel.append({ app: items[i].app || "App", body: items[i].body || "" })
                                            } catch(e) {}
                                        }
                                    }
                                }
                                Timer { interval: 4000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { nF.running=false; nF.running=true } }
                            }
                        }
                    }

                    // System stats poller
                    Process {
                        id: sysFetch
                        command: ["bash", "-c", "echo $(top -bn1 | awk '/Cpu/{print int($2)}') $(free | awk '/Mem/{print int($3/$2*100)}') $(df / | awk 'NR==2{print int($5)}' | tr -d '%') $(uptime -p | sed 's/up //')"]
                        running: true
                        stdout: StdioCollector {
                            onStreamFinished: {
                                let p = this.text.trim().split(" ")
                                cpuTxt.text = (p[0]||"0") + "%"
                                ramTxt.text = (p[1]||"0") + "%"
                                dskTxt.text = (p[2]||"0") + "%"
                                upTxt.text = "up " + p.slice(3).join(" ")
                            }
                        }
                    }
                    Timer { interval: 5000; running: true; repeat: true; triggeredOnStart: true; onTriggered: { sysFetch.running=false; sysFetch.running=true } }
                }
            }
        }
    }
}

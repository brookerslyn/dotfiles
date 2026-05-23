import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../"

ShellRoot {
    id: root

    Caching { id: paths }
    MatugenColors { id: _theme }

    readonly property color bg: _theme.base
    readonly property color card: _theme.surface0
    readonly property color text: _theme.text
    readonly property color subtext: _theme.subtext0
    readonly property color accent: _theme.blue
    readonly property color accentDim: _theme.sapphire
    readonly property color field: _theme.mantle
    readonly property color error: _theme.red
    readonly property color divider: _theme.overlay0

    property string wallpaperPath: "file://" + paths.getCacheDir("lock") + "/lock_wallpaper.png"

    Timer {
        id: pamActionTimer
        interval: 50
        onTriggered: pam.start()
    }

    Timer {
        id: unlockTimer
        interval: 700
        onTriggered: { rootLock.locked = false; Qt.quit() }
    }

    PamContext {
        id: pam
        config: "quickshell"
        Component.onCompleted: pamActionTimer.start()

        onResponseRequiredChanged: {
            if (responseRequired && root.pendingPassword !== "") {
                pam.respond(root.pendingPassword)
                root.pendingPassword = ""
            }
        }

        onCompleted: (result) => {
            if (result === PamResult.Success) {
                cardExitAnim.start()
                unlockTimer.start()
            } else {
                errText.text = "wrong password"
                errText.visible = true
                pwd.text = ""
                root.pendingPassword = ""
                pamActionTimer.start()
            }
        }

        onError: (error) => {
        }
    }

    property string pendingPassword: ""

    PanelWindow {
        id: rootLock
        property bool locked: true
        visible: locked
        WlrLayershell.namespace: "lock"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"

        Item {
            id: screen
            anchors.fill: parent
            readonly property real sc: height / 768

            // Background
            Image {
                id: bgImg
                width: parent.width
                height: parent.height
                source: root.wallpaperPath
                fillMode: Image.PreserveAspectCrop
                cache: false
            }

            // Slight dim
            Rectangle {
                id: dimRect
                width: parent.width
                height: parent.height
                color: Qt.rgba(0, 0, 0, 0.15)
            }

            // Card
            Rectangle {
                id: card
                x: (screen.width - width) / 2
                y: (screen.height - height) / 2
                width: 300 * screen.sc
                height: cardCol.height + 60 * screen.sc
                radius: 20 * screen.sc
                color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.55)
                border.width: 1
                border.color: Qt.rgba(root.text.r, root.text.g, root.text.b, 0.08)

                opacity: 0
                scale: 0.95
                Component.onCompleted: cardAnim.start()

                ParallelAnimation {
                    id: cardAnim
                    NumberAnimation { target: card; property: "opacity"; to: 1; duration: 600; easing.type: Easing.OutCubic }
                    NumberAnimation { target: card; property: "scale"; to: 1.0; duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
                }

                ParallelAnimation {
                    id: cardExitAnim
                    // Curtain reveal - everything slides up off-screen
                    NumberAnimation { target: bgImg; property: "y"; to: -screen.height; duration: 700; easing.type: Easing.InOutQuart }
                    NumberAnimation { target: card; property: "y"; to: -screen.height; duration: 700; easing.type: Easing.InOutQuart }
                    NumberAnimation { target: dimRect; property: "y"; to: -screen.height; duration: 700; easing.type: Easing.InOutQuart }
                }

                Column {
                    id: cardCol
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 30 * screen.sc
                    anchors.leftMargin: 30 * screen.sc
                    anchors.rightMargin: 30 * screen.sc
                    spacing: 0

                    // Greeting
                    Text {
                        text: {
                            var h = new Date().getHours()
                            if (h < 12) return "☕ good morning"
                            if (h < 17) return "☕ good afternoon"
                            return "🌙 good evening"
                        }
                        color: root.accent
                        font.pixelSize: 14 * screen.sc
                        font.letterSpacing: 2
                    }

                    Item { width: 1; height: 6 * screen.sc }

                    // Clock
                    Text {
                        id: clockText
                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: root.text
                        font.pixelSize: 48 * screen.sc
                        font.weight: Font.Light
                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
                        }
                    }

                    // Date
                    Text {
                        text: Qt.formatDate(new Date(), "dddd, MMMM d").toLowerCase()
                        color: root.subtext
                        font.pixelSize: 13 * screen.sc
                        font.letterSpacing: 1
                    }

                    Item { width: 1; height: 24 * screen.sc }

                    // Divider
                    Rectangle {
                        width: parent.width; height: 1
                        color: root.divider; opacity: 0.3
                    }

                    Item { width: 1; height: 24 * screen.sc }

                    // Username
                    Row {
                        spacing: 10 * screen.sc
                        Rectangle {
                            width: 3 * screen.sc; height: 20 * screen.sc
                            radius: 1.5; color: root.accent
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: Quickshell.env("USER").toUpperCase()
                            color: root.text
                            font.pixelSize: 20 * screen.sc
                            font.letterSpacing: 0.5
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    Item { width: 1; height: 20 * screen.sc }

                    // Password field
                    Rectangle {
                        width: parent.width; height: 44 * screen.sc
                        radius: 14 * screen.sc
                        color: root.field
                        border.width: 1.5
                        border.color: pwd.activeFocus ? root.accent : Qt.rgba(root.divider.r, root.divider.g, root.divider.b, 0.3)
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Text {
                            anchors.centerIn: parent
                            text: "password"
                            color: root.subtext
                            opacity: pwd.text.length === 0 ? 0.6 : 0
                            font.pixelSize: 13 * screen.sc
                            font.letterSpacing: 2
                        }

                        TextInput {
                            id: pwd
                            anchors.fill: parent
                            anchors.leftMargin: 20 * screen.sc
                            anchors.rightMargin: 20 * screen.sc
                            color: root.text
                            font.pixelSize: 14 * screen.sc
                            font.letterSpacing: 8
                            echoMode: TextInput.Password
                            passwordCharacter: "•"
                            horizontalAlignment: TextInput.AlignHCenter
                            verticalAlignment: TextInput.AlignVCenter
                            clip: true
                            focus: true
                            cursorVisible: false
                            onTextEdited: { errText.text = ""; errText.visible = false }
                            Keys.onReturnPressed: screen.doLogin()
                            Keys.onEnterPressed: screen.doLogin()
                            Keys.onEscapePressed: { rootLock.locked = false; Qt.quit() }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: pwd.forceActiveFocus()
                        }
                    }

                    Item { width: 1; height: 12 * screen.sc }

                    // Error
                    Text {
                        id: errText
                        text: ""; visible: false
                        color: root.error
                        font.pixelSize: 11 * screen.sc
                        font.letterSpacing: 1
                    }


                    Item { width: 1; height: 8 * screen.sc }

                    // Login button
                    Rectangle {
                        id: loginBtn
                        width: parent.width; height: 44 * screen.sc
                        radius: 14 * screen.sc
                        color: loginMa.containsMouse ? root.accent : root.accentDim
                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "LOGIN"
                            color: root.bg
                            font.pixelSize: 14 * screen.sc
                            font.letterSpacing: 3
                            font.weight: Font.Medium
                        }

                        MouseArea {
                            id: loginMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: screen.doLogin()
                        }
                    }
                }
            }

            Timer {
                interval: 300; running: true
                onTriggered: pwd.forceActiveFocus()
            }

            function doLogin() {
                if (pwd.text.length > 0) {
                    pwCheck.command = ["bash", "-c", "echo '" + pwd.text.replace(/'/g, "'\\''") + "' | su -c true 2>&1 && echo OK || echo FAIL"]
                    pwCheck.running = true
                }
            }

            Process {
                id: pwCheck
                stdout: StdioCollector {
                    onStreamFinished: {
                        let out = this.text.trim()
                        if (out.endsWith("OK")) {
                            cardExitAnim.start()
                            unlockTimer.start()
                        } else {
                            errText.text = "wrong password"
                            errText.visible = true
                            pwd.text = ""
                        }
                    }
                }
            }
        }
    }
}

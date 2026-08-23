import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// General Settings window — scoped to only the values that are genuinely
// live/rebuild-free today (Wi-Fi/Bluetooth power, volume, wallpaper via
// hyprpaper IPC, monitor scale via hyprctl, read-only system info). No
// save/cancel: every control writes straight through to the live service
// the instant it's touched, same as the bar's own popups.
FloatingWindow {
    id: root

    property string activeSection: "network"

    title: "Settings"
    visible: false
    implicitWidth: 560
    implicitHeight: 420
    color: "transparent"

    Colors { id: colors }
    Tokens { id: tokens }

    Rectangle {
        anchors.fill: parent
        radius: tokens.roundingNormal
        color: colors.mantle
        border.color: colors.surface1
        border.width: 1

        Row {
            id: mainRow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: powerBar.top
            }

            Column {
                id: sidebar
                width: 140
                height: parent.height
                topPadding: 12
                spacing: 2

                Repeater {
                    model: [
                        { key: "network", label: "Network" },
                        { key: "audio", label: "Audio" },
                        { key: "wallpaper", label: "Wallpaper" },
                        { key: "display", label: "Display" },
                        { key: "about", label: "About" }
                    ]

                    delegate: Rectangle {
                        readonly property bool active: root.activeSection === modelData.key

                        x: 8
                        width: sidebar.width - 16
                        height: 30
                        radius: 6
                        color: active ? Qt.alpha(colors.blue, 0.14) : "transparent"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            text: modelData.label
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: active ? colors.text : colors.subtext0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.activeSection = modelData.key
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: colors.surface1
            }

            Flickable {
                width: parent.width - sidebar.width - 1
                height: parent.height
                contentWidth: width
                contentHeight: content.implicitHeight + 32
                clip: true

                Column {
                    id: content
                    x: 16
                    y: 16
                    width: parent.width - 32
                    spacing: 16

                    NetworkSettingsSection { width: content.width; visible: root.activeSection === "network" }
                    AudioSettingsSection { width: content.width; visible: root.activeSection === "audio" }
                    WallpaperSettingsSection { width: content.width; visible: root.activeSection === "wallpaper" }
                    DisplaySettingsSection { width: content.width; visible: root.activeSection === "display" }
                    AboutSettingsSection { width: content.width; visible: root.activeSection === "about" }
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: powerBar.top
            }
            height: 1
            color: colors.surface1
        }

        // lock/logout/restart/shutdown — always visible regardless of the
        // active section. "Log Out" asks Hyprland itself to quit (the
        // "exit" dispatcher, sent over the same IPC socket Hyprland.dispatch()
        // already uses elsewhere in this bar); restart/shutdown are plain
        // systemd calls; lock just runs hyprlock directly, same binary the
        // mainMod+L keybind in hyprland.lua already launches.
        Item {
            id: powerBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 48

            Process { id: actionProc }
            function run(args) {
                if (actionProc.running) return;
                actionProc.command = args;
                actionProc.running = true;
            }

            Row {
                anchors.centerIn: parent
                spacing: 12

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Lock"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["hyprlock", "--immediate-render"])
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Log Out"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("exit")
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Restart"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["systemctl", "reboot"])
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: Qt.alpha(colors.red, 0.12)
                    border.width: 1
                    border.color: Qt.alpha(colors.red, 0.4)

                    Text {
                        anchors.centerIn: parent
                        text: "Shut Down"
                        color: colors.red
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["systemctl", "poweroff"])
                    }
                }
            }
        }
    }
}

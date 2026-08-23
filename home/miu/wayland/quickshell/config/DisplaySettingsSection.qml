import QtQuick
import Quickshell.Hyprland
import Quickshell.Io

// lists monitors via Hyprland's IPC (read-only: name/resolution/scale) and
// applies a scale preset live via `hyprctl keyword monitor ...`. Quickshell's
// own Hyprland.dispatch() only ever sends the "dispatch" socket verb, not
// "keyword", so applying a mode change has to shell out to hyprctl directly
// (same Process pattern as the wallpaper section).
Column {
    id: root
    spacing: 16

    Colors { id: colors }
    Tokens { id: tokens }

    function applyScale(monitorName, scale) {
        if (applyProc.running) return;
        applyProc.command = ["hyprctl", "keyword", "monitor", monitorName + ",preferred,auto," + scale];
        applyProc.running = true;
        Hyprland.refreshMonitors();
    }

    Process {
        id: applyProc
    }

    Repeater {
        model: Hyprland.monitors.values

        delegate: Column {
            width: root.width
            spacing: 6

            Text {
                text: modelData.name + "  " + modelData.width + "x" + modelData.height
                color: colors.text
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.bold: true
            }

            SettingsRow {
                width: root.width
                label: "Scale"

                Row {
                    spacing: 4

                    Rectangle {
                        width: 40
                        height: 22
                        radius: 5
                        color: Math.abs(modelData.scale - 1.0) < 0.01 ? Qt.alpha(colors.blue, 0.2) : "transparent"
                        border.width: 1
                        border.color: Qt.alpha(colors.overlay0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: "1.0"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Math.abs(modelData.scale - 1.0) < 0.01 ? colors.blue : colors.subtext0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyScale(modelData.name, 1.0)
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 22
                        radius: 5
                        color: Math.abs(modelData.scale - 1.25) < 0.01 ? Qt.alpha(colors.blue, 0.2) : "transparent"
                        border.width: 1
                        border.color: Qt.alpha(colors.overlay0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: "1.25"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Math.abs(modelData.scale - 1.25) < 0.01 ? colors.blue : colors.subtext0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyScale(modelData.name, 1.25)
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 22
                        radius: 5
                        color: Math.abs(modelData.scale - 1.5) < 0.01 ? Qt.alpha(colors.blue, 0.2) : "transparent"
                        border.width: 1
                        border.color: Qt.alpha(colors.overlay0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: "1.5"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Math.abs(modelData.scale - 1.5) < 0.01 ? colors.blue : colors.subtext0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyScale(modelData.name, 1.5)
                        }
                    }

                    Rectangle {
                        width: 40
                        height: 22
                        radius: 5
                        color: Math.abs(modelData.scale - 2.0) < 0.01 ? Qt.alpha(colors.blue, 0.2) : "transparent"
                        border.width: 1
                        border.color: Qt.alpha(colors.overlay0, 0.3)
                        Text {
                            anchors.centerIn: parent
                            text: "2.0"
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 11
                            color: Math.abs(modelData.scale - 2.0) < 0.01 ? colors.blue : colors.subtext0
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.applyScale(modelData.name, 2.0)
                        }
                    }
                }
            }
        }
    }
}

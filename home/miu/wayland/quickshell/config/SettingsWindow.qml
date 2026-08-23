import QtQuick
import Quickshell

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
            anchors.fill: parent

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
    }
}

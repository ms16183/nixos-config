import QtQuick
import Quickshell
import Quickshell.Bluetooth

// hyprpanel: bluetooth.label = false -> icon only. click for a native
// device list/pairing panel (replaces blueman-manager; blueman is still
// installed, just no longer the primary UI here).
Item {
    id: root

    implicitWidth: 20
    implicitHeight: 28

    Colors { id: colors }
    Tokens { id: tokens }

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false

    // M3 "state layer": a soft highlight that fades in on hover
    Rectangle {
        anchors.fill: parent
        radius: tokens.roundingFull
        color: colors.surface0
        opacity: mouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: tokens.emphasizedDuration / 4 }
        }
    }

    Text {
        anchors.centerIn: parent
        color: colors.text
        font.family: "Symbols Nerd Font"
        font.pixelSize: 16
        text: root.powered ? "\u{f00af}" : "\u{f00b2}" // md-bluetooth / md-bluetooth_off
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
            margins: -8
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: popup.open = !popup.open
    }

    PopupWindow {
        id: popup

        property bool open: false
        readonly property real targetHeight: Math.min(360, Math.max(90, contentColumn.implicitHeight + 16))
        // NOTE: the window's own implicitHeight must stay fixed — animating
        // a wlr-layer-shell popup surface down to 0px height crashed the
        // whole quickshell process (which took the bar down with it). the
        // "grow" effect below animates a plain Item inside a fixed-size
        // window instead.
        visible: open || revealAnim.running

        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.margins.top: 8

        implicitWidth: 260
        implicitHeight: targetHeight
        color: "transparent"

        Item {
            id: reveal
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            clip: true
            height: popup.open ? popup.targetHeight : 0

            Behavior on height {
                NumberAnimation {
                    id: revealAnim
                    duration: tokens.spatialDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: tokens.spatialCurve
                }
            }

        Rectangle {
            width: parent.width
            height: popup.targetHeight
            radius: tokens.roundingNormal
            color: colors.mantle
            border.color: colors.surface1
            border.width: 1

            Column {
                id: contentColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 8
                }
                spacing: 8

                // header: power + scan toggles
                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.adapter?.name ?? "Bluetooth"
                        color: colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item { width: parent.width - powerLabel.width - scanLabel.width - 16; height: 1 }

                    Text {
                        id: scanLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.adapter?.discovering ? "Scanning…" : "Scan"
                        color: colors.blue
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!root.adapter) return;
                                if (root.adapter.discovering) root.adapter.stopDiscovery();
                                else root.adapter.startDiscovery();
                            }
                        }
                    }

                    Text {
                        id: powerLabel
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.powered ? "On" : "Off"
                        color: root.powered ? colors.green : colors.overlay0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: colors.surface1 }

                Text {
                    visible: !root.adapter || root.adapter.devices.values.length === 0
                    text: "No devices"
                    color: colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Repeater {
                    model: root.adapter ? root.adapter.devices.values : []

                    delegate: Rectangle {
                        width: contentColumn.width
                        implicitHeight: deviceRow.implicitHeight + 12
                        radius: tokens.roundingSmall
                        color: colors.surface0

                        Row {
                            id: deviceRow
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: 8
                            }
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width - statusText.width - 8
                                text: modelData.name
                                color: colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            Text {
                                id: statusText
                                anchors.verticalCenter: parent.verticalCenter
                                text:
                                    modelData.connected ? "Connected"
                                    : modelData.pairing ? "Pairing…"
                                    : modelData.paired ? "Paired"
                                    : "Pair"
                                color: modelData.connected ? colors.green : colors.subtext0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (!modelData.paired) modelData.pair();
                                else if (modelData.connected) modelData.disconnect();
                                else modelData.connect();
                            }
                        }
                    }
                }
            }
        }
        }
    }
}

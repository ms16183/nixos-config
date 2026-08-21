import QtQuick
import Quickshell
import Quickshell.Networking

// hyprpanel: network.label = false -> icon only. click for a native wifi
// network list (replaces nm-connection-editor; network-manager-applet is
// still installed, just no longer the primary UI here).
Item {
    id: root

    implicitWidth: 20
    implicitHeight: 28

    Colors { id: colors }
    Tokens { id: tokens }

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (const d of devices) if (d.type === DeviceType.Wifi) return d;
        return null;
    }
    readonly property bool connected: wifiDevice?.connected ?? false
    readonly property bool anyWired: Networking.devices.values.some(
        d => d.type === DeviceType.Wired && d.connected
    )

    // network expanded for password entry, if any
    property var pskTarget: null

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
        text:
            root.connected ? "\u{f05a9}"  // md-wifi
            : root.anyWired ? "\u{f0200}" // md-ethernet
            : "\u{f05aa}"                 // md-wifi_off
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
            margins: -8
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (root.wifiDevice) root.wifiDevice.scannerEnabled = true;
            popup.open = !popup.open;
        }
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

        onOpenChanged: if (!open) root.pskTarget = null

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

                Row {
                    width: parent.width
                    spacing: 8

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Wi-Fi"
                        color: colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Item {
                        width: parent.width - wifiToggle.width - 60
                        height: 1
                    }

                    Text {
                        id: wifiToggle
                        anchors.verticalCenter: parent.verticalCenter
                        text: Networking.wifiEnabled ? "On" : "Off"
                        color: Networking.wifiEnabled ? colors.green : colors.overlay0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                        }
                    }
                }

                Rectangle { width: parent.width; height: 1; color: colors.surface1 }

                Text {
                    visible: !root.wifiDevice || root.wifiDevice.networks.values.length === 0
                    text: Networking.wifiEnabled ? "Scanning…" : "Wi-Fi is off"
                    color: colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Repeater {
                    model: root.wifiDevice ? root.wifiDevice.networks.values : []

                    delegate: Column {
                        width: contentColumn.width
                        spacing: 4

                        Rectangle {
                            width: parent.width
                            implicitHeight: netRow.implicitHeight + 12
                            radius: tokens.roundingSmall
                            color: colors.surface0

                            Row {
                                id: netRow
                                anchors {
                                    left: parent.left
                                    right: parent.right
                                    verticalCenter: parent.verticalCenter
                                    margins: 8
                                }
                                spacing: 8

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - sigText.width - 8
                                    text: modelData.name
                                    color: colors.text
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 12
                                    elide: Text.ElideRight
                                }

                                Text {
                                    id: sigText
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: modelData.connected
                                        ? "Connected"
                                        : Math.round(modelData.signalStrength * 100) + "%"
                                    color: modelData.connected ? colors.green : colors.subtext0
                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 11
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.connected) {
                                        modelData.disconnect();
                                    } else if (modelData.known || modelData.security === WifiSecurityType.Open) {
                                        modelData.connect();
                                    } else {
                                        root.pskTarget = root.pskTarget === modelData ? null : modelData;
                                    }
                                }
                            }
                        }

                        // password entry, shown only for the selected secured network
                        Row {
                            visible: root.pskTarget === modelData
                            width: parent.width
                            spacing: 6

                            TextInput {
                                id: pskInput
                                width: parent.width - connectBtn.width - 6
                                height: 24
                                color: colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                echoMode: TextInput.Password
                                clip: true

                                Rectangle {
                                    z: -1
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    radius: 4
                                    color: colors.surface0
                                    border.color: colors.surface1
                                    border.width: 1
                                }

                                onAccepted: {
                                    modelData.connectWithPsk(text);
                                    root.pskTarget = null;
                                }
                            }

                            Text {
                                id: connectBtn
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Connect"
                                color: colors.blue
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        modelData.connectWithPsk(pskInput.text);
                                        root.pskTarget = null;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        }
    }
}

import QtQuick
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Io

// Wi-Fi/Bluetooth power toggles (live bindings, same as the bar popups) plus
// the same per-network/per-device list content those popups already show.
// IPv4 details (method/address/gateway/DNS) aren't exposed by Quickshell's
// own Networking API at all (checked: Device/Network/Wifi/Wired only expose
// name/address/connected/state/security/signalStrength — nothing about IP
// config), so that part shells out to `nmcli` directly instead.
Column {
    id: root
    spacing: 16

    readonly property var wifiDevice: {
        const devices = Networking.devices.values;
        for (const d of devices) if (d.type === DeviceType.Wifi) return d;
        return null;
    }
    readonly property var adapter: Bluetooth.defaultAdapter
    property var pskTarget: null

    Colors { id: colors }
    Tokens { id: tokens }

    // ---------------- Wi-Fi ----------------
    Column {
        width: root.width
        spacing: 8

        SettingsToggleRow {
            width: root.width
            label: "Wi-Fi"
            checked: Networking.wifiEnabled
            onToggled: c => Networking.wifiEnabled = c
        }

        Text {
            visible: !root.wifiDevice || root.wifiDevice.networks.values.length === 0
            text: "No networks found"
            color: colors.subtext0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
        }

        Repeater {
            model: root.wifiDevice ? root.wifiDevice.networks.values : []

            delegate: Column {
                width: root.width
                spacing: 4

                Rectangle {
                    width: root.width
                    implicitHeight: wifiRow.implicitHeight + 16
                    radius: tokens.roundingSmall
                    color: colors.surface0

                    Row {
                        id: wifiRow
                        anchors {
                            left: parent.left
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: 10
                        }
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: colors.text
                            text: modelData.connected ? "\u{f05a9}" : "\u{f05aa}" // md-wifi / md-wifi_off
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - statusCol.width - 30
                            text: modelData.name
                            color: colors.text
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }

                        Column {
                            id: statusCol
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 1

                            Text {
                                text: modelData.connected ? "Connected" : Math.round(modelData.signalStrength * 100) + "%"
                                color: modelData.connected ? colors.green : colors.subtext0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                            }

                            Text {
                                text: modelData.security !== WifiSecurityType.Open ? "Secured" : "Open"
                                color: colors.subtext0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 10
                            }
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
                    width: root.width
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

        // Wayland has no XEmbed-style mechanism to embed another process's
        // window inside this one, so nm-connection-editor (subnet/DHCP/DNS
        // per-connection editing that goes well beyond what's built above)
        // just gets launched as its own window instead.
        Rectangle {
            width: 200
            height: 28
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: Qt.alpha(colors.overlay0, 0.3)

            Text {
                anchors.centerIn: parent
                text: "Open Wi-Fi Connections…"
                color: colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (nmEditorProc.running) return;
                    nmEditorProc.command = ["nm-connection-editor"];
                    nmEditorProc.running = true;
                }
            }
        }

        Process { id: nmEditorProc }
    }

    Rectangle { width: root.width; height: 1; color: colors.surface1 }

    IPv4DetailsSection {
        width: root.width
        interfaceName: root.wifiDevice ? root.wifiDevice.name : ""
    }

    Rectangle { width: root.width; height: 1; color: colors.surface1 }

    // ---------------- Bluetooth ----------------
    Column {
        width: root.width
        spacing: 8

        SettingsToggleRow {
            width: root.width
            label: "Bluetooth"
            enabled: root.adapter !== null
            checked: root.adapter?.enabled ?? false
            onToggled: c => { if (root.adapter) root.adapter.enabled = c; }
        }

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
                width: root.width
                implicitHeight: btRow.implicitHeight + 16
                radius: tokens.roundingSmall
                color: colors.surface0

                Row {
                    id: btRow
                    anchors {
                        left: parent.left
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        margins: 10
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

        // same reasoning as the Wi-Fi button above — no way to embed
        // blueman-manager's window, so it just opens on its own.
        Rectangle {
            width: 200
            height: 28
            radius: 6
            color: "transparent"
            border.width: 1
            border.color: Qt.alpha(colors.overlay0, 0.3)

            Text {
                anchors.centerIn: parent
                text: "Open Bluetooth Devices…"
                color: colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (bluemanProc.running) return;
                    bluemanProc.command = ["blueman-manager"];
                    bluemanProc.running = true;
                }
            }
        }

        Process { id: bluemanProc }
    }
}

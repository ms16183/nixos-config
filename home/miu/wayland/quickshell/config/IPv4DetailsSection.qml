import QtQuick
import Quickshell.Io

// IPv4 method/address/gateway/DNS for whatever NetworkManager connection is
// currently active on `interfaceName`. Quickshell's own Networking API has
// no IP-configuration surface at all, so this talks to `nmcli` directly —
// every nmcli call here is a plain argv list (no `sh -c`, no shell
// quoting to get wrong) run as two sequential steps (modify, then up) so a
// failed modify never reaches the activation step.
Column {
    id: root
    spacing: 8

    property string interfaceName: ""
    property string connectionName: ""
    property string method: ""
    property bool manualMode: false
    property string statusMsg: ""

    Colors { id: colors }
    Tokens { id: tokens }

    onInterfaceNameChanged: if (interfaceName) refresh()
    Component.onCompleted: if (interfaceName) refresh()

    function refresh() {
        statusMsg = "";
        connNameProc.command = ["nmcli", "-t", "-f", "GENERAL.CONNECTION", "device", "show", root.interfaceName];
        connNameProc.running = false;
        connNameProc.running = true;
    }

    function apply() {
        if (!root.connectionName) return;
        statusMsg = "Applying…";
        if (root.manualMode) {
            modifyProc.command = ["nmcli", "connection", "modify", root.connectionName,
                "ipv4.method", "manual",
                "ipv4.addresses", addrInput.text,
                "ipv4.gateway", gwInput.text,
                "ipv4.dns", dnsInput.text];
        } else {
            modifyProc.command = ["nmcli", "connection", "modify", root.connectionName, "ipv4.method", "auto"];
        }
        modifyProc.running = false;
        modifyProc.running = true;
    }

    Process {
        id: connNameProc
        stdout: StdioCollector {
            onStreamFinished: {
                const idx = text.indexOf(":");
                const name = idx !== -1 ? text.slice(idx + 1).trim() : "";
                root.connectionName = (name && name !== "--") ? name : "";
                if (root.connectionName) {
                    detailsProc.running = false;
                    detailsProc.running = true;
                }
            }
        }
    }

    Process {
        id: detailsProc
        command: ["nmcli", "-t", "-f", "ipv4.method,ipv4.addresses,ipv4.gateway,ipv4.dns", "connection", "show", root.connectionName]
        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of text.split("\n")) {
                    const idx = line.indexOf(":");
                    if (idx === -1) continue;
                    const key = line.slice(0, idx);
                    const val = line.slice(idx + 1);
                    if (key === "ipv4.method") { root.method = val; root.manualMode = (val === "manual"); }
                    else if (key === "ipv4.addresses") addrInput.text = val;
                    else if (key === "ipv4.gateway") gwInput.text = val;
                    else if (key === "ipv4.dns") dnsInput.text = val;
                }
            }
        }
    }

    Process {
        id: modifyProc
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.statusMsg = text.trim()
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                upProc.command = ["nmcli", "connection", "up", root.connectionName];
                upProc.running = false;
                upProc.running = true;
            } else if (root.statusMsg === "Applying…") {
                root.statusMsg = "Failed to modify (exit " + exitCode + ")";
            }
        }
    }

    Process {
        id: upProc
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.statusMsg = text.trim()
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.statusMsg = "Applied";
                root.refresh();
            } else if (root.statusMsg === "Applying…") {
                root.statusMsg = "Modified, but activation failed (exit " + exitCode + ")";
            }
        }
    }

    Text {
        text: "IPv4" + (root.interfaceName ? " (" + root.interfaceName + ")" : "")
        color: colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        font.bold: true
    }

    Text {
        visible: !root.connectionName
        text: root.interfaceName ? "No active connection on this interface" : "No Wi-Fi interface"
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
    }

    Column {
        visible: root.connectionName !== ""
        width: root.width
        spacing: 6

        SettingsRow {
            width: root.width
            label: "Mode"

            Row {
                spacing: 4

                Rectangle {
                    width: 90; height: 22; radius: 5
                    color: !root.manualMode ? Qt.alpha(colors.blue, 0.2) : "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)
                    Text {
                        anchors.centerIn: parent
                        text: "Automatic"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: !root.manualMode ? colors.blue : colors.subtext0
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.manualMode = false }
                }

                Rectangle {
                    width: 90; height: 22; radius: 5
                    color: root.manualMode ? Qt.alpha(colors.blue, 0.2) : "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)
                    Text {
                        anchors.centerIn: parent
                        text: "Manual"
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                        color: root.manualMode ? colors.blue : colors.subtext0
                    }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.manualMode = true }
                }
            }
        }

        SettingsRow {
            width: root.width
            label: "Address (CIDR)"

            TextInput {
                id: addrInput
                width: 200
                height: 20
                enabled: root.manualMode
                color: root.manualMode ? colors.text : colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
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
            }
        }

        SettingsRow {
            width: root.width
            label: "Gateway"

            TextInput {
                id: gwInput
                width: 200
                height: 20
                enabled: root.manualMode
                color: root.manualMode ? colors.text : colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
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
            }
        }

        SettingsRow {
            width: root.width
            label: "DNS"

            TextInput {
                id: dnsInput
                width: 200
                height: 20
                enabled: root.manualMode
                color: root.manualMode ? colors.text : colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
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
            }
        }

        Row {
            spacing: 8

            Rectangle {
                width: 70; height: 24; radius: 5
                color: Qt.alpha(colors.blue, 0.16)
                border.width: 1
                border.color: Qt.alpha(colors.blue, 0.4)
                Text { anchors.centerIn: parent; text: "Apply"; color: colors.blue; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 11 }
                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.apply() }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                visible: root.statusMsg !== ""
                text: root.statusMsg
                color: colors.subtext0
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 11
            }
        }
    }
}

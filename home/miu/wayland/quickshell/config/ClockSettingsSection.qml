import QtQuick
import Quickshell
import Quickshell.Io

// Current time is just a live clock (same pattern as Clock.qml). Timezone
// is genuinely runtime-changeable via `timedatectl set-timezone` — systemd
// owns /etc/localtime and NixOS's own time.timeZone activation script only
// re-asserts it on the next rebuild, so this behaves like the bar's other
// "live but not Nix-persisted" controls (Wi-Fi/Bluetooth power, volume).
// Locale/language is read-only: changing `i18n.defaultLocale` needs a
// rebuild + new login session, there's no live equivalent to call into.
Column {
    id: root
    spacing: 8

    property string currentTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    property string timezone: "…"
    property string locale: "…"
    property string statusMsg: ""

    Colors { id: colors }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    }

    function refresh() {
        statusMsg = "";
        tzProc.running = false;
        tzProc.running = true;
        root.locale = Quickshell.env("LANG") || "Unknown";
    }

    function applyTimezone() {
        if (!tzInput.text) return;
        root.statusMsg = "Applying…";
        setTzProc.command = ["timedatectl", "set-timezone", tzInput.text];
        setTzProc.running = false;
        setTzProc.running = true;
    }

    onVisibleChanged: if (visible) refresh()
    Component.onCompleted: refresh()

    Process {
        id: tzProc
        command: ["timedatectl", "show", "--property=Timezone", "--value"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.timezone = text.trim();
                tzInput.text = root.timezone;
            }
        }
    }

    Process {
        id: setTzProc
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.statusMsg = text.trim()
        }
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.statusMsg = "Applied";
                root.refresh();
            } else if (root.statusMsg === "Applying…") {
                root.statusMsg = "Failed (exit " + exitCode + ") — is \"" + tzInput.text + "\" a valid IANA timezone name?";
            }
        }
    }

    SettingsInfoRow { width: root.width; label: "Current Time"; value: root.currentTime }

    SettingsRow {
        width: root.width
        label: "Timezone"

        Row {
            spacing: 6

            TextInput {
                id: tzInput
                width: 170
                height: 20
                color: colors.text
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

                onAccepted: root.applyTimezone()
            }

            Rectangle {
                width: 60
                height: 22
                radius: 5
                color: Qt.alpha(colors.blue, 0.16)
                border.width: 1
                border.color: Qt.alpha(colors.blue, 0.4)

                Text {
                    anchors.centerIn: parent
                    text: "Apply"
                    color: colors.blue
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.applyTimezone()
                }
            }
        }
    }

    Text {
        visible: root.statusMsg !== ""
        width: root.width
        text: root.statusMsg
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
        wrapMode: Text.Wrap
    }

    SettingsInfoRow { width: root.width; label: "Language (locale)"; value: root.locale }
}

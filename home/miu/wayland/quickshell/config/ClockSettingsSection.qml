import QtQuick
import Quickshell
import Quickshell.Io

// Current time is just a live clock (same pattern as Clock.qml). Timezone
// and locale are both read-only: NixOS keeps /etc/localtime as a read-only
// store symlink (confirmed live — `timedatectl set-timezone` here fails
// with "read-only file system", unlike a typical distro where it's
// writable), and `i18n.defaultLocale` similarly needs a rebuild + new login
// session. Both are `time.timeZone` / `i18n.defaultLocale` in the Nix
// config, not something this window can change.
Column {
    id: root
    spacing: 8

    property string currentTime: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    property string timezone: "…"
    property string locale: "…"

    Colors { id: colors }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    }

    function refresh() {
        tzProc.running = false;
        tzProc.running = true;
        root.locale = Quickshell.env("LANG") || "Unknown";
    }

    Component.onCompleted: refresh()

    Process {
        id: tzProc
        command: ["timedatectl", "show", "--property=Timezone", "--value"]
        stdout: StdioCollector {
            onStreamFinished: root.timezone = text.trim()
        }
    }

    SettingsInfoRow { width: root.width; label: "Current Time"; value: root.currentTime }
    SettingsInfoRow { width: root.width; label: "Timezone"; value: root.timezone }
    SettingsInfoRow { width: root.width; label: "Language (locale)"; value: root.locale }
}

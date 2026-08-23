import QtQuick
import Quickshell.Io

// pure read-only system info — not a "setting", just live process reads.
Column {
    id: root
    spacing: 0

    property string osName: "…"
    property string kernel: "…"
    property string qsVersion: "…"
    property string uptime: "…"

    Colors { id: colors }

    Process {
        running: true
        command: ["sh", "-c", "grep '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '\"'"]
        stdout: SplitParser { onRead: data => root.osName = data }
    }

    Process {
        running: true
        command: ["uname", "-r"]
        stdout: SplitParser { onRead: data => root.kernel = data }
    }

    Process {
        running: true
        command: ["sh", "-c", "quickshell --version 2>/dev/null || qs --version 2>/dev/null || echo unknown"]
        stdout: SplitParser { onRead: data => root.qsVersion = data }
    }

    Process {
        running: true
        command: ["uptime", "-p"]
        stdout: SplitParser { onRead: data => root.uptime = data }
    }

    SettingsInfoRow { width: root.width; label: "OS"; value: root.osName }
    SettingsInfoRow { width: root.width; label: "Kernel"; value: root.kernel }
    SettingsInfoRow { width: root.width; label: "QuickShell"; value: root.qsVersion }
    SettingsInfoRow { width: root.width; label: "Uptime"; value: root.uptime }
}

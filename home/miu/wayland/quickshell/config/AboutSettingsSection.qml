import QtQuick
import Quickshell
import Quickshell.Io

// pure read-only system info. Reads /proc directly instead of shelling out
// to `uptime`/`lscpu`/`free` — those come from procps/util-linux, which
// aren't guaranteed to be installed (this repo doesn't list them in
// environment.systemPackages), and that's why uptime previously showed
// nothing. /proc/{uptime,cpuinfo,meminfo} always exist, no extra package
// needed.
Column {
    id: root
    spacing: 0

    property string osName: "…"
    property string kernel: "…"
    property string qsVersion: "…"
    property string uptime: "…"
    property string cpu: "…"
    property string memory: "…"
    property string shell: "…"

    Colors { id: colors }

    FileView { id: osRelease; path: "/etc/os-release" }
    FileView { id: uptimeFile; path: "/proc/uptime" }
    FileView { id: cpuInfoFile; path: "/proc/cpuinfo" }
    FileView { id: memInfoFile; path: "/proc/meminfo" }

    function refresh() {
        // os-release: PRETTY_NAME="..."
        const rel = osRelease.text();
        const relMatch = rel.match(/^PRETTY_NAME="?([^"\n]*)"?/m);
        root.osName = relMatch ? relMatch[1] : "Unknown";

        // /proc/uptime: "<seconds since boot> <idle seconds>"
        const upSecs = parseFloat(uptimeFile.text().trim().split(" ")[0]);
        if (!isNaN(upSecs)) {
            const days = Math.floor(upSecs / 86400);
            const hours = Math.floor((upSecs % 86400) / 3600);
            const mins = Math.floor((upSecs % 3600) / 60);
            const parts = [];
            if (days > 0) parts.push(days + "d");
            if (hours > 0 || days > 0) parts.push(hours + "h");
            parts.push(mins + "m");
            root.uptime = parts.join(" ");
        }

        // /proc/cpuinfo: "model name\t: <name>"
        const cpuMatch = cpuInfoFile.text().match(/^model name\s*:\s*(.+)$/m);
        root.cpu = cpuMatch ? cpuMatch[1].trim() : "Unknown";

        // /proc/meminfo: "MemTotal:     16384000 kB"
        const memMatch = memInfoFile.text().match(/^MemTotal:\s*(\d+)\s*kB/m);
        root.memory = memMatch ? (Math.round(parseInt(memMatch[1]) / 1024 / 1024 * 10) / 10) + " GiB" : "Unknown";

    }

    Process {
        running: true
        command: ["uname", "-r"]
        stdout: SplitParser { onRead: data => root.kernel = data }
    }

    Process {
        running: true
        command: ["sh", "-c", "\"$SHELL\" --version 2>/dev/null | head -n1 || echo unknown"]
        stdout: SplitParser { onRead: data => root.shell = data }
    }

    Process {
        running: true
        command: ["sh", "-c", "quickshell --version 2>/dev/null || qs --version 2>/dev/null || echo unknown"]
        stdout: SplitParser { onRead: data => root.qsVersion = data }
    }

    onVisibleChanged: if (visible) refresh()
    Component.onCompleted: refresh()

    SettingsInfoRow { width: root.width; label: "OS"; value: root.osName }
    SettingsInfoRow { width: root.width; label: "Kernel"; value: root.kernel }
    SettingsInfoRow { width: root.width; label: "CPU"; value: root.cpu }
    SettingsInfoRow { width: root.width; label: "Memory"; value: root.memory }
    SettingsInfoRow { width: root.width; label: "Shell"; value: root.shell }
    SettingsInfoRow { width: root.width; label: "QuickShell"; value: root.qsVersion }
    SettingsInfoRow { width: root.width; label: "Uptime"; value: root.uptime }
    // QuickShell's own license — static, not a runtime query.
    SettingsInfoRow { width: root.width; label: "License"; value: "LGPL-3.0" }
}

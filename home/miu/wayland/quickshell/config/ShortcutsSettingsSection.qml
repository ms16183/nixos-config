import QtQuick
import Quickshell.Io

// reads the live keybind list straight from Hyprland (`hyprctl binds -j`)
// rather than re-parsing hyprland.lua ourselves — this is always in sync
// with what's actually bound, submaps included. Only binds with a
// `description` set (via hl.bind(..., { description = "..." }) in
// hyprland.lua) are shown, since the raw dispatcher/arg fields alone
// aren't a readable label.
Column {
    id: root
    spacing: 4

    property var binds: []

    Colors { id: colors }

    function modText(modmask) {
        const parts = [];
        if (modmask & 64) parts.push("Super");
        if (modmask & 4) parts.push("Ctrl");
        if (modmask & 8) parts.push("Alt");
        if (modmask & 1) parts.push("Shift");
        return parts;
    }

    function keyText(key) {
        if (!key) return "";
        if (key.startsWith("mouse:")) {
            const code = key.split(":")[1];
            if (code === "272") return "LMB";
            if (code === "273") return "RMB";
            if (code === "274") return "MMB";
            return "Mouse " + code;
        }
        if (key.startsWith("code:")) {
            const code = parseInt(key.split(":")[1]);
            // our workspace binds use physical keycodes 10-18 for "1"-"9"
            // (see the loop comment in hyprland.lua)
            if (code >= 10 && code <= 18) return String(code - 9);
            return "Key " + code;
        }
        if (key.startsWith("XF86") || key.startsWith("switch:")) return key;
        if (key.length === 1) return key.toUpperCase();
        return key.charAt(0).toUpperCase() + key.slice(1).toLowerCase();
    }

    function formatBind(b) {
        const parts = modText(b.modmask);
        parts.push(keyText(b.key));
        return parts.join(" + ");
    }

    function refresh() {
        bindsProc.running = false;
        bindsProc.running = true;
    }

    onVisibleChanged: if (visible) refresh()

    Text {
        visible: root.binds.length === 0
        text: "No shortcuts found"
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
    }

    Repeater {
        model: root.binds

        delegate: SettingsInfoRow {
            width: root.width
            label: modelData.description
            value: root.formatBind(modelData)
        }
    }

    Process {
        id: bindsProc
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    root.binds = parsed.filter(b => b.description && b.description.length > 0);
                } catch (e) {
                    root.binds = [];
                }
            }
        }
    }

    Component.onCompleted: refresh()
}

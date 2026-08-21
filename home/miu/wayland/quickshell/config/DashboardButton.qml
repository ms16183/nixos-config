import QtQuick
import Quickshell.Hyprland

// placeholder for hyprpanel's "dashboard" module.
// hyprpanel's own dashboard has directories/resourceUsage disabled, so for
// now this just opens the app launcher. build out a real quick-settings
// panel here later.
Item {
    id: root

    implicitWidth: 32
    implicitHeight: 28

    Colors { id: colors }

    Text {
        anchors.centerIn: parent
        text: "\u{f313}" // nf-linux-nixos
        color: colors.text
        // font-logos glyphs (nf-linux-*) aren't in the Symbols Nerd Font
        // (symbols-only) subset — use the full JetBrainsMono Nerd Font
        // patch instead, same lesson as the fa-th swap before it.
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 18
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("exec rofi -show drun")
    }
}

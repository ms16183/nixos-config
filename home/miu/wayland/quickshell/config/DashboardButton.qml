import QtQuick

// opens SettingsWindow.qml (shell.qml wires `onClicked` to toggle the
// window's `visible`, since ids aren't visible across component files).
// the app launcher this used to open is still reachable via the
// mainMod+R keybind in hyprland.lua.
Item {
    id: root

    implicitWidth: 32
    implicitHeight: 28

    signal clicked()

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
        onClicked: root.clicked()
    }
}

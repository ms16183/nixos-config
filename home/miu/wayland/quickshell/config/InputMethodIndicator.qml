import QtQuick
import Quickshell.Hyprland

// fcitx5's own tray icon depends on Qt's QIcon::fromTheme() lookup, which
// isn't resolving here (same class of issue as the other tofu icons) — so
// this queries fcitx5 directly over its "-remote" CLI/DBus client instead
// and renders the EN/JA indicator ourselves.
// flags confirmed against fcitx5's own src/tools/remote.cpp.
Item {
    id: root

    implicitWidth: 22
    implicitHeight: 28

    Colors { id: colors }

    property string currentIm: ""
    readonly property bool japanese: currentIm.indexOf("mozc") !== -1

    PollingProcess {
        interval: 2000
        command: ["fcitx5-remote", "-n"]
        onResult: output => root.currentIm = output.trim()
    }

    Rectangle {
        anchors.centerIn: parent
        width: 20
        height: 18
        radius: 4
        color: root.japanese ? colors.yellow : "transparent"
        border.color: root.japanese ? "transparent" : colors.overlay0
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: root.japanese ? "あ" : "EN"
            color: root.japanese ? colors.crust : colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: root.japanese ? 13 : 10
            font.bold: true
        }
    }

    // toggles fcitx5's active input method within the current group
    // (equivalent to the usual Ctrl+Space/Fn trigger key)
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Hyprland.dispatch("exec fcitx5-remote -t")
    }
}

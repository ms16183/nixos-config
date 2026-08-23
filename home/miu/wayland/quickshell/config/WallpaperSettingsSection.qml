import QtQuick
import Quickshell
import Quickshell.Io

// lists images in ~/Pictures/wallpapers and applies the picked one live via
// hyprpaper's IPC (hyprctl hyprpaper wallpaper "<mon>,<path>,<fit>"), per
// https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/#ipc — run as a Process
// (argv list, no shell involved) so paths need no quoting/escaping.
Column {
    id: root
    spacing: 8

    readonly property string wallpaperDir: Quickshell.env("HOME") + "/Pictures/wallpapers"
    property var files: []
    property string activeWallpaper: ""

    Colors { id: colors }
    Tokens { id: tokens }

    Text {
        text: root.wallpaperDir
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
    }

    Text {
        visible: root.files.length === 0
        text: "No images found"
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
    }

    Grid {
        width: root.width
        columns: 3
        spacing: 8

        Repeater {
            model: root.files

            delegate: Rectangle {
                readonly property bool active: modelData === root.activeWallpaper

                width: (root.width - 16) / 3
                height: width * 0.6
                radius: tokens.roundingSmall
                color: colors.surface0
                border.width: active ? 2 : 1
                border.color: active ? colors.blue : colors.surface1
                clip: true

                Image {
                    anchors.fill: parent
                    source: "file://" + modelData
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (applyProc.running) return;
                        applyProc.command = ["hyprctl", "hyprpaper", "wallpaper", "," + modelData + ",cover"];
                        applyProc.running = true;
                        root.activeWallpaper = modelData;
                    }
                }
            }
        }
    }

    Process {
        id: listProc
        command: ["find", root.wallpaperDir, "-maxdepth", "1", "-type", "f", "-regextype", "posix-extended",
                  "-iregex", ".*\\.(jpg|jpeg|png|webp)"]
        stdout: SplitParser {
            onRead: data => { if (data) root.files = [...root.files, data]; }
        }
        onExited: activeProc.running = true
    }

    Process {
        id: activeProc
        command: ["hyprctl", "hyprpaper", "listactive"]
        stdout: SplitParser {
            onRead: data => {
                const idx = data.indexOf(": ");
                if (idx !== -1) root.activeWallpaper = data.slice(idx + 2).trim();
            }
        }
    }

    Process {
        id: applyProc
    }

    Component.onCompleted: listProc.running = true
}

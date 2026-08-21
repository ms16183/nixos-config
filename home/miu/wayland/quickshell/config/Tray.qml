import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root
    spacing: 6
    implicitHeight: 28

    Repeater {
        // blueman-manager registers its own tray icon while its window is
        // open (redundant with BluetoothStatus.qml's dedicated indicator),
        // and fcitx5's tray icon never resolves through Qt's icon-theme
        // lookup (redundant with InputMethodIndicator.qml) — hide both.
        model: SystemTray.items.values.filter(item =>
            !/blue(man|tooth)/i.test(item.id) && !/blue(man|tooth)/i.test(item.title)
            && !/fcitx/i.test(item.id) && !/fcitx/i.test(item.title)
        )

        delegate: IconImage {
            implicitSize: 18
            // modelData.icon is already a ready-to-use image source (SNI
            // spec's icon string, resolved by quickshell itself) — do not
            // re-run it through Quickshell.iconPath(), which expects a bare
            // freedesktop icon *name* and produced a broken/tofu icon here.
            source: modelData.icon

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: modelData.activate()
            }
        }
    }
}

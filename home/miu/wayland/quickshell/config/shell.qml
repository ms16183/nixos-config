import Quickshell
import Quickshell.Wayland
import QtQuick

// bar layout mirrors home/miu/wayland/hyprpanel/default.nix:
//   left   = [ dashboard, workspaces ]
//   middle = [ ]
//   right  = [ volume, network, bluetooth, fcitx5, systray, battery, notifications, clock ]
// left/right are anchored independently (not a single RowLayout with a
// fillWidth spacer) since nesting RowLayouts that way was pushing the
// right-hand items over to the left instead of anchoring them to the edge.
//
// visual style follows vast-shell (github.com/myamusashi/vast-shell): a
// Material-3-ish surface pill with rounded bottom corners, instead of the
// flat fully-transparent bar this started as. the pill itself is
// translucent and blurred by Hyprland (see layerrule in
// wayland/hyprland/default.nix), matching regular window transparency.
ShellRoot {
    SettingsWindow {
        id: settingsWindow
    }

    PanelWindow {
        id: bar

        WlrLayershell.namespace: "quickshell:bar"

        Colors { id: colors }
        Tokens { id: tokens }

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 36
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: Qt.alpha(colors.mantle, 0.55)
            radius: 0
            bottomLeftRadius: tokens.roundingLarge
            bottomRightRadius: tokens.roundingLarge
        }

        Row {
            anchors {
                left: parent.left
                leftMargin: tokens.spacingNormal
                verticalCenter: parent.verticalCenter
            }
            spacing: tokens.spacingNormal
            DashboardButton {
                onClicked: settingsWindow.visible = !settingsWindow.visible
            }
            Workspaces {}
        }

        Row {
            anchors {
                right: parent.right
                rightMargin: tokens.spacingNormal
                verticalCenter: parent.verticalCenter
            }
            spacing: tokens.spacingNormal
            VolumeIndicator {}
            NetworkStatus {}
            BluetoothStatus {}
            InputMethodIndicator {}
            Tray {}
            BatteryStatus {}
            NotificationsIndicator {}
            Clock {}
        }
    }
}

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
    // recreated fresh each time it's opened (Loader.active toggles
    // construction/destruction) rather than a persistent instance whose
    // `visible` gets flipped — Hyprland's mainMod+Q (`hl.dsp.window.close()`)
    // closes this window's real toplevel surface out from under Quickshell,
    // and re-showing that same now-closed instance never worked afterwards.
    // Popups in this bar already use the equivalent pattern successfully
    // (PopupWindow recreates on every open), so this window now does too.
    Loader {
        id: settingsLoader
        active: false
        sourceComponent: SettingsWindow {}
        // closed() fires for any close, compositor-driven (mainMod+Q) or
        // otherwise — without this, closing the window any way other than
        // the dashboard toggle leaves `active` stuck true, so the next
        // click would just tear down the (already-gone) window instead of
        // opening a new one.
        onLoaded: item.closed.connect(() => { settingsLoader.active = false; })
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
                onClicked: settingsLoader.active = !settingsLoader.active
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

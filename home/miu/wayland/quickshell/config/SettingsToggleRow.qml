import QtQuick

// SettingsRow + a pill switch. `checked` is meant to be bound to a live
// property (e.g. `checked: Networking.wifiEnabled`); clicking never writes
// `checked` itself — it only emits `toggled(!checked)` so the binding to
// the real live value stays intact and flows back into the pill visually.
SettingsRow {
    id: root

    // `enabled` is not redeclared here — Item (SettingsRow's base type)
    // already provides it; reusing the inherited one below.
    property bool checked: false
    signal toggled(bool checked)

    Colors { id: colors }
    Tokens { id: tokens }

    Rectangle {
        width: 32
        height: 17
        radius: 9
        opacity: root.enabled ? 1 : 0.4
        color: root.checked ? Qt.alpha(colors.blue, 0.35) : Qt.alpha(colors.overlay0, 0.15)
        border.color: root.checked ? Qt.alpha(colors.blue, 0.55) : Qt.alpha(colors.overlay0, 0.3)
        border.width: 1

        Rectangle {
            width: 13
            height: 13
            radius: 6.5
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 2 : 2
            color: root.checked ? colors.blue : colors.overlay0

            Behavior on x {
                NumberAnimation { duration: tokens.emphasizedDuration / 4 }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled: root.enabled
            cursorShape: Qt.PointingHandCursor
            onClicked: root.toggled(!root.checked)
        }
    }
}

import QtQuick

// M3 "state layer": a soft highlight that fades in on hover. Shared by
// every bar icon that has one (Volume/Bluetooth/Network/Notifications/Clock).
Rectangle {
    id: root

    property bool active: false

    anchors.fill: parent
    radius: tokens.roundingFull
    color: colors.surface0
    opacity: active ? 1 : 0

    Colors { id: colors }
    Tokens { id: tokens }

    Behavior on opacity {
        NumberAnimation { duration: tokens.emphasizedDuration / 4 }
    }
}

import QtQuick

// bar icon that opens SettingsWindow.qml — shell.qml wires `onClicked` to
// toggle the window's `visible` (ids aren't visible across component
// files, so the wiring lives in shell.qml, which has both in scope).
Item {
    id: root

    implicitWidth: 24
    implicitHeight: 28

    signal clicked()

    Colors { id: colors }
    Tokens { id: tokens }

    Rectangle {
        anchors.fill: parent
        radius: tokens.roundingFull
        color: colors.surface0
        opacity: mouseArea.containsMouse ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: tokens.emphasizedDuration / 4 }
        }
    }

    Text {
        anchors.centerIn: parent
        text: "" // nf-fa-gear
        color: colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 15
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

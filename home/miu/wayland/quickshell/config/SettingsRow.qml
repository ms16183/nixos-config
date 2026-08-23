import QtQuick

// one row inside the settings window: a label on the left, free content on
// the right, bottom hairline — shared base for SettingsToggleRow /
// SettingsSliderRow / SettingsInfoRow.
Item {
    id: root

    default property alias content: contentArea.data
    property string label: ""

    implicitHeight: 34

    Colors { id: colors }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        color: colors.text
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
    }

    Item {
        id: contentArea
        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 1
        color: colors.surface1
        opacity: 0.4
    }
}

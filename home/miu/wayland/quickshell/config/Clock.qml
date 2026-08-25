import QtQuick

// hyprpanel: clock.format = "%H:%M". hover for the full date+time.
Item {
    id: root

    Colors { id: colors }
    Tokens { id: tokens }

    implicitWidth: label.implicitWidth + 16
    implicitHeight: 28

    HoverHighlight { active: mouseArea.containsMouse }

    Text {
        id: label
        anchors.centerIn: parent
        color: colors.lavender
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 14
        font.bold: true
        text: Qt.formatDateTime(new Date(), "HH:mm")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            label.text = Qt.formatDateTime(new Date(), "HH:mm");
            popup.detailText = Qt.formatDateTime(new Date(), "yyyy/MM/dd HH:mm:ss");
        }
    }

    MouseArea {
        id: mouseArea
        // the tight text bounding box made the hover region flicker on
        // tiny mouse movements — pad it out generously.
        anchors {
            fill: parent
            margins: -8
        }
        hoverEnabled: true
    }

    AnimatedPopup {
        id: popup
        anchorItem: root
        iconHovered: mouseArea.containsMouse
        targetHeight: 44
        implicitWidth: 200

        property string detailText: Qt.formatDateTime(new Date(), "yyyy/MM/dd HH:mm:ss")

        Text {
            anchors.centerIn: parent
            text: popup.detailText
            color: colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 14
        }
    }
}

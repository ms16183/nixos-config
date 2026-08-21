import QtQuick

// minimal drag/click-to-set slider, used for the volume mixer popup.
Item {
    id: root

    property real value: 0 // 0-1
    property color trackColor: "#333333"
    property color fillColor: "#ffffff"

    signal moved(real value)

    implicitHeight: 16

    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: root.trackColor

        Rectangle {
            width: track.width * Math.max(0, Math.min(1, root.value))
            height: track.height
            radius: track.radius
            color: root.fillColor
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function update(x) {
            root.moved(Math.max(0, Math.min(1, x / width)));
        }

        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => { if (pressed) update(mouse.x); }
    }
}

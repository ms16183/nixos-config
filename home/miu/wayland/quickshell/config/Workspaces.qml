import QtQuick
import Quickshell.Hyprland

// hyprpanel: workspaces.show_numbers = false, show_icons = true
// visual style follows vast-shell's "dot" workspace indicator: the active
// workspace morphs into a pill, occupied ones are dim dots, empty ones are
// dimmer still.
Row {
    id: root
    spacing: 6

    Colors { id: colors }
    Tokens { id: tokens }

    Repeater {
        model: 9

        Item {
            id: delegateRoot

            property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
            property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
            property bool isOccupied: !!ws

            implicitWidth: 24
            implicitHeight: 28

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                implicitWidth: delegateRoot.isActive ? 24 : 8
                implicitHeight: 8
                radius: tokens.roundingFull
                color: delegateRoot.isActive ? colors.blue : colors.text
                opacity: delegateRoot.isActive ? 1.0 : (delegateRoot.isOccupied ? 0.6 : 0.3)

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: tokens.emphasizedDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: tokens.emphasizedCurve
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: tokens.emphasizedDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: tokens.emphasizedCurve
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + (index + 1))
            }
        }
    }
}

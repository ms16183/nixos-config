import QtQuick
import Quickshell

// hyprpanel: clock.format = "%H:%M". hover for the full date+time.
Item {
    id: root

    Colors { id: colors }
    Tokens { id: tokens }

    implicitWidth: label.implicitWidth + 16
    implicitHeight: 28

    // M3 "state layer": a soft highlight that fades in on hover
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
        onEntered: {
            hideTimer.stop();
            popup.open = true;
        }
        onExited: hideTimer.restart()
    }

    // debounce hiding too, so crossing the boundary between the icon and
    // the popup itself doesn't cause a flicker
    Timer {
        id: hideTimer
        interval: 150
        onTriggered: popup.open = false
    }

    PopupWindow {
        id: popup

        property string detailText: Qt.formatDateTime(new Date(), "yyyy/MM/dd HH:mm:ss")
        property bool open: false
        // NOTE: the window's own implicitHeight must stay fixed — animating
        // a wlr-layer-shell popup surface down to 0px height crashed the
        // whole quickshell process (which took the bar down with it). the
        // "grow" effect below animates a plain Item inside a fixed-size
        // window instead.
        visible: open || revealAnim.running

        // anchor to the bottom of the icon so the popup opens below the
        // bar instead of overlapping it.
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        anchor.margins.top: 8

        implicitWidth: 200
        implicitHeight: 44
        color: "transparent"

        Item {
            id: reveal
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            clip: true
            height: popup.open ? 44 : 0

            Behavior on height {
                NumberAnimation {
                    id: revealAnim
                    duration: tokens.spatialDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: tokens.spatialCurve
                }
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: tokens.roundingNormal
                color: colors.mantle
                border.color: colors.surface1
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: popup.detailText
                    color: colors.text
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// hyprpanel: notifications module, label = false -> icon only.
// left click toggles a panel listing tracked notifications; right click
// mutes/unmutes (bell vs bell-slash). click a notification in the panel
// to dismiss it.
Item {
    id: root

    implicitWidth: 24
    implicitHeight: 28

    Colors { id: colors }
    Tokens { id: tokens }

    property bool muted: false

    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
        }
    }

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
        anchors.centerIn: parent
        color: root.muted ? colors.overlay0 : colors.text
        font.family: "Symbols Nerd Font"
        font.pixelSize: 16
        text: root.muted ? "\u{f009b}" : "\u{f009a}" // md-bell_off / md-bell
    }

    Rectangle {
        visible: server.trackedNotifications.length > 0
        width: 6
        height: 6
        radius: tokens.roundingFull
        color: colors.red
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 2
            rightMargin: 2
        }
    }

    MouseArea {
        id: mouseArea
        anchors {
            fill: parent
            margins: -8
        }
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.RightButton
        onClicked: root.muted = !root.muted
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

        property bool open: false
        readonly property real targetHeight: Math.min(400, Math.max(56, listColumn.implicitHeight + 16))
        // NOTE: the window's own implicitHeight must stay fixed — animating
        // a wlr-layer-shell popup surface down to 0px height crashed the
        // whole quickshell process (which took the bar down with it). the
        // "grow" effect below animates a plain Item inside a fixed-size
        // window instead.
        visible: open || revealAnim.running

        // anchor to the bottom of the icon so the panel opens below the bar
        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Right
        anchor.gravity: Edges.Bottom | Edges.Left
        // negative bottom margin (not a positive top margin — anchor.margins
        // shrinks the anchor *rect*, and edges:Bottom keys off the rect's
        // bottom edge, so only the bottom margin affects the gap here)
        // pushes the popup 8px clear of the bar below the icon.
        anchor.margins.bottom: -8

        implicitWidth: 280
        implicitHeight: targetHeight
        color: "transparent"

        Item {
            id: reveal
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            clip: true
            height: popup.open ? popup.targetHeight : 0

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
                height: popup.targetHeight
                radius: tokens.roundingNormal
                color: colors.mantle
                border.color: colors.surface1
                border.width: 1

                Column {
                    id: listColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }
                    spacing: 6

                Text {
                    visible: server.trackedNotifications.length === 0
                    text: "No notifications"
                    color: colors.subtext0
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12
                }

                Repeater {
                    model: server.trackedNotifications

                    delegate: Rectangle {
                        width: listColumn.width
                        implicitHeight: entryColumn.implicitHeight + 12
                        radius: tokens.roundingSmall
                        color: colors.surface0

                        Column {
                            id: entryColumn
                            anchors {
                                left: parent.left
                                right: parent.right
                                verticalCenter: parent.verticalCenter
                                margins: 8
                            }
                            spacing: 2

                            Text {
                                width: parent.width
                                text: modelData.summary
                                color: colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                font.bold: true
                                wrapMode: Text.Wrap
                            }

                            Text {
                                width: parent.width
                                visible: modelData.body.length > 0
                                text: modelData.body
                                color: colors.subtext0
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 11
                                wrapMode: Text.Wrap
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.tracked = false
                        }
                    }
                }
            }
        }
    }
    }
}

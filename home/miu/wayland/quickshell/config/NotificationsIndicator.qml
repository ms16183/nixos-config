import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// hyprpanel: notifications module, label = false -> icon only.
// hover shows a panel listing tracked notifications; right click
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

    HoverHighlight { active: mouseArea.containsMouse }

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
    }

    AnimatedPopup {
        id: popup
        anchorItem: root
        iconHovered: mouseArea.containsMouse
        targetHeight: Math.min(400, Math.max(56, listColumn.implicitHeight + 16))
        // anchor to the bottom of the icon so the panel opens below the bar
        edges: Edges.Bottom | Edges.Right
        gravity: Edges.Bottom | Edges.Left
        implicitWidth: 280

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

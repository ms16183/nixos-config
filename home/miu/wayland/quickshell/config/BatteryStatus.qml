import QtQuick
import Quickshell
import Quickshell.Services.UPower

// hyprpanel: battery.label = false -> icon only. hover for percentage + status.
Item {
    id: root

    visible: UPower.displayDevice?.isLaptopBattery ?? false
    implicitWidth: visible ? 28 : 0
    implicitHeight: 28

    Colors { id: colors }
    Tokens { id: tokens }

    readonly property var device: UPower.displayDevice
    // UPower's own "Percentage" DBus property is 0-100, but quickshell's
    // device.hpp doc comment defines this one as literally energy/energyCapacity
    // (a 0-1 ratio) — that mismatch was silently halving our reading down to
    // ~1%. Normalize defensively instead of trusting either convention blindly.
    readonly property real rawPercentage: device?.percentage ?? 0
    readonly property real percentage: rawPercentage > 1 ? rawPercentage / 100 : rawPercentage
    readonly property bool charging: device?.state === UPowerDeviceState.Charging

    // battery shape (body + fill + tip) with the percentage overlaid inside
    // the body itself, matched to vast-shell's Widgets/Battery.qml.
    Item {
        anchors.centerIn: parent
        width: batteryBody.width + tip.width
        height: 28

        Rectangle {
            id: batteryBody

            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
            }
            implicitWidth: 26
            implicitHeight: 13
            clip: true
            color: "transparent"
            radius: tokens.roundingSmall * 0.5

            border {
                width: 2
                color: root.percentage <= 0.2 && !root.charging ? colors.red : Qt.alpha(colors.overlay0, 0.6)
            }

            Rectangle {
                anchors {
                    left: parent.left
                    leftMargin: 2
                    top: parent.top
                    topMargin: 2
                    bottom: parent.bottom
                    bottomMargin: 2
                }
                implicitWidth: (parent.width - 4) * root.percentage
                radius: parent.radius > 2 ? parent.radius - 2 : 0
                color:
                    root.charging ? colors.green
                    : root.percentage <= 0.2 ? colors.red
                    : root.percentage <= 0.5 ? colors.yellow
                    : colors.text

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: tokens.spatialDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: tokens.spatialCurve
                    }
                }
            }

            Text {
                anchors.centerIn: parent
                text: Math.round(root.percentage * 100)
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: batteryBody.height * 0.6
                font.bold: true
                // contrast against whatever's directly behind the digits:
                // mostly-empty body (background shows through) -> light text,
                // mostly-full body (light fill color) -> dark text.
                color: root.percentage <= 0.5 ? colors.text : colors.crust
            }
        }

        Rectangle {
            id: tip
            implicitWidth: 2
            implicitHeight: 5
            anchors {
                left: batteryBody.right
                leftMargin: 0.5
                verticalCenter: batteryBody.verticalCenter
            }
            color: root.percentage <= 0.2 && !root.charging ? colors.red : Qt.alpha(colors.overlay0, 0.6)
            topRightRadius: 1
            bottomRightRadius: 1
        }
    }

    MouseArea {
        // pad the hover region beyond the 20x20 icon so tiny mouse
        // movements near the edge don't flicker the popup open/closed.
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
        implicitHeight: 64
        color: "transparent"

        Item {
            id: reveal
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
            clip: true
            height: popup.open ? 64 : 0

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
                height: 64
                radius: tokens.roundingNormal
                color: colors.mantle
                border.color: colors.surface1
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: Math.round(root.percentage * 100) + "%"
                        color: colors.text
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14
                        font.bold: true
                    }

                    Text {
                        text: root.device ? UPowerDeviceState.toString(root.device.state) : "Unknown"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// hyprpanel: volume.label = false, but the user asked for the number too —
// icon + % in the bar. click opens a per-app mixer (master + each playback
// stream), matched to a typical pavucontrol-style "Playback" tab.
Item {
    id: root

    implicitWidth: percentLabel.implicitWidth + 4 + 20
    implicitHeight: 28

    Colors { id: colors }
    Tokens { id: tokens }

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    // playback streams (apps producing sound), e.g. browser/terminal/music
    // player — PwNodeType.AudioOutStream is Audio|Sink|Stream, so isStream
    // && isSink && audio != null selects exactly those.
    readonly property var appStreams: Pipewire.nodes.values.filter(
        n => n.isStream && n.isSink && n.audio
    )

    PwObjectTracker {
        objects: root.appStreams
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

    Row {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: colors.text
            font.family: "Symbols Nerd Font"
            font.pixelSize: 16
            text:
                root.muted ? "\u{f0581}"        // md-volume_off
                : root.volume > 0.5 ? "\u{f057e}" // md-volume_high
                : root.volume > 0 ? "\u{f0580}"   // md-volume_medium
                : "\u{f057f}"                     // md-volume_low
        }

        Text {
            id: percentLabel
            anchors.verticalCenter: parent.verticalCenter
            color: colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
            text: Math.round(root.volume * 100) + "%"
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton && root.sink?.audio) {
                root.sink.audio.muted = !root.sink.audio.muted;
            } else if (mouse.button === Qt.LeftButton) {
                popup.open = !popup.open;
            }
        }
        onWheel: wheel => {
            if (!root.sink?.audio) return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + delta));
        }
    }

    PopupWindow {
        id: popup

        property bool open: false
        readonly property real targetHeight: Math.min(400, Math.max(100, mixerColumn.implicitHeight + 16))
        // NOTE: the window's own implicitHeight must stay fixed — animating
        // a wlr-layer-shell popup surface down to 0px height crashed the
        // whole quickshell process (which took the bar down with it). the
        // "grow" effect below animates a plain Item inside a fixed-size
        // window instead.
        visible: open || revealAnim.running

        anchor.item: root
        anchor.edges: Edges.Bottom | Edges.Left
        anchor.gravity: Edges.Bottom | Edges.Right
        // negative bottom margin (not a positive top margin — anchor.margins
        // shrinks the anchor *rect*, and edges:Bottom keys off the rect's
        // bottom edge, so only the bottom margin affects the gap here)
        // pushes the popup 8px clear of the bar below the icon.
        anchor.margins.bottom: -8

        implicitWidth: 260
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
                    id: mixerColumn
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: parent.top
                        margins: 8
                    }
                    spacing: 8

                    Text {
                        text: "Master"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    Row {
                        width: parent.width
                        spacing: 8

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            color: colors.text
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            text: root.muted ? "\u{f0581}" : "\u{f057e}"
                        }

                        Slider {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 30
                            value: root.volume
                            trackColor: colors.surface0
                            fillColor: root.muted ? colors.overlay0 : colors.blue
                            onMoved: v => { if (root.sink?.audio) root.sink.audio.volume = v; }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: colors.surface1 }

                    Text {
                        visible: root.appStreams.length === 0
                        text: "No apps playing audio"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 12
                    }

                    Repeater {
                        model: root.appStreams

                        delegate: Column {
                            width: mixerColumn.width
                            spacing: 2

                            Text {
                                width: parent.width
                                text: modelData.properties["application.name"] || modelData.description || modelData.name
                                color: colors.text
                                font.family: "JetBrainsMono Nerd Font"
                                font.pixelSize: 12
                                elide: Text.ElideRight
                            }

                            Row {
                                width: parent.width
                                spacing: 8

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    color: colors.text
                                    font.family: "Symbols Nerd Font"
                                    font.pixelSize: 13
                                    text: modelData.audio.muted ? "\u{f0581}" : "\u{f057e}"

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: modelData.audio.muted = !modelData.audio.muted
                                    }
                                }

                                Slider {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width - 26
                                    value: modelData.audio.volume
                                    trackColor: colors.surface0
                                    fillColor: modelData.audio.muted ? colors.overlay0 : colors.mauve
                                    onMoved: v => modelData.audio.volume = v
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

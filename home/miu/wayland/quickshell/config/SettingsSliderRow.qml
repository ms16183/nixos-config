import QtQuick

// SettingsRow + the bar's existing Slider.qml, plus a percentage readout.
// `value` (0-1) is meant to be bound to a live property; `onMoved` should
// write straight through to that live property, same as VolumeIndicator.qml.
SettingsRow {
    id: root

    property real value: 0 // 0-1
    signal moved(real value)

    Colors { id: colors }

    Row {
        spacing: 8

        Slider {
            id: slider
            width: 140
            anchors.verticalCenter: parent.verticalCenter
            value: root.value
            trackColor: colors.surface0
            fillColor: colors.blue
            onMoved: v => root.moved(v)
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            width: 34
            horizontalAlignment: Text.AlignRight
            text: Math.round(root.value * 100) + "%"
            color: colors.subtext0
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 11
        }
    }
}

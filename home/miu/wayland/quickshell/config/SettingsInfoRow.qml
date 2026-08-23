import QtQuick

// SettingsRow + a plain read-only value (used by the About section).
SettingsRow {
    id: root

    property string value: ""

    Colors { id: colors }

    Text {
        text: root.value
        color: colors.subtext0
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 11
    }
}

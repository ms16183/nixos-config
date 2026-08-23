import QtQuick
import Quickshell.Services.Pipewire

// output volume — same live PwObjectTracker/audio.volume binding
// VolumeIndicator.qml already uses.
Column {
    id: root
    spacing: 0

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio?.volume ?? 0
    readonly property bool muted: sink?.audio?.muted ?? false

    SettingsSliderRow {
        width: root.width
        label: "Output volume"
        value: root.volume
        onMoved: v => { if (root.sink?.audio) root.sink.audio.volume = v; }
    }

    SettingsToggleRow {
        width: root.width
        label: "Mute"
        enabled: root.sink !== null
        checked: root.muted
        onToggled: c => { if (root.sink?.audio) root.sink.audio.muted = c; }
    }
}

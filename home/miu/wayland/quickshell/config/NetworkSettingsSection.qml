import QtQuick
import Quickshell.Networking
import Quickshell.Bluetooth

// Wi-Fi / Bluetooth power toggles — same live bindings NetworkStatus.qml
// and BluetoothStatus.qml already use for their bar-popup toggles.
Column {
    id: root
    spacing: 0

    readonly property var adapter: Bluetooth.defaultAdapter

    SettingsToggleRow {
        width: root.width
        label: "Wi-Fi"
        checked: Networking.wifiEnabled
        onToggled: c => Networking.wifiEnabled = c
    }

    SettingsToggleRow {
        width: root.width
        label: "Bluetooth"
        enabled: root.adapter !== null
        checked: root.adapter?.enabled ?? false
        onToggled: c => { if (root.adapter) root.adapter.enabled = c; }
    }
}

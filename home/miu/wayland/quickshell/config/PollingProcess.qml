import QtQuick
import Quickshell.Io

// runs `command` on an interval and emits its stdout as `result`.
// shared by NetworkStatus.qml and BluetoothStatus.qml so the
// process-restart dance only needs to be gotten right once.
Item {
    id: root

    property alias command: proc.command
    property int interval: 10000

    signal result(string output)

    function refresh() {
        buffer = "";
        proc.running = false;
        proc.running = true;
    }

    property string buffer: ""

    Process {
        id: proc
        stdout: SplitParser {
            onRead: data => root.buffer += data + "\n"
        }
        onExited: {
            root.result(root.buffer);
            root.buffer = "";
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}

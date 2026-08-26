import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

// General Settings window — scoped to only the values that are genuinely
// live/rebuild-free today (Wi-Fi/Bluetooth power, volume, wallpaper via
// hyprpaper IPC, monitor scale via hyprctl, read-only system info). No
// save/cancel: every control writes straight through to the live service
// the instant it's touched, same as the bar's own popups.
//
// Layout matches the "2a" mockup: every section renders at once in one
// continuous scroll, and the left sidebar is a jump-to-anchor nav (click
// = smooth-scroll to that section's header), not a tab switcher — plus the
// active sidebar entry tracks whichever section is currently at the top
// of the viewport while scrolling, same as the mockup's own behavior.
FloatingWindow {
    id: root

    property string activeSection: "network"
    readonly property var sectionLabels: ({
        network: "Network",
        audio: "Audio",
        wallpaper: "Wallpaper",
        display: "Display",
        clock: "Clock",
        about: "About"
    })
    property var sectionAnchors: ({})
    readonly property var sectionOrder: ["network", "audio", "wallpaper", "display", "clock", "about"]

    function scrollTo(key) {
        const item = sectionAnchors[key];
        if (!item) return;
        scrollArea.contentY = Math.max(0, Math.min(
            content.y + item.y,
            scrollArea.contentHeight - scrollArea.height
        ));
        root.activeSection = key;
    }

    title: "Settings"
    visible: false
    // sections are instantiated once and just shown/hidden with the whole
    // window (not recreated per open), so their own Component.onCompleted
    // only fires once at quickshell startup — refresh anything that can go
    // stale (wallpaper directory contents, About's live system info)
    // whenever the window is actually opened instead.
    onVisibleChanged: {
        if (visible) {
            wallpaperSection.rescan();
            aboutSection.refresh();
            clockSection.refresh();
        }
    }
    implicitWidth: 620
    implicitHeight: 600
    color: "transparent"

    Colors { id: colors }
    Tokens { id: tokens }

    Rectangle {
        anchors.fill: parent
        // matches hyprland.lua's decoration.rounding (10), not
        // tokens.roundingNormal (17) — this window is a regular Hyprland
        // toplevel, so the compositor itself clips/rounds its actual
        // corners at decoration.rounding; a larger radius here than that
        // left a visible gap between this rectangle's corner and the
        // window's real (tighter) rounded-corner clip.
        radius: 10
        color: colors.mantle
        border.color: colors.surface1
        border.width: 1

        Row {
            id: mainRow
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                bottom: powerBar.top
            }

            Column {
                id: sidebar
                width: 140
                height: parent.height
                topPadding: 12
                spacing: 2

                Repeater {
                    model: root.sectionOrder

                    delegate: Rectangle {
                        readonly property bool active: root.activeSection === modelData

                        x: 8
                        width: sidebar.width - 16
                        height: 30
                        radius: 6
                        color: active ? Qt.alpha(colors.blue, 0.14) : "transparent"

                        Text {
                            anchors {
                                left: parent.left
                                leftMargin: 10
                                verticalCenter: parent.verticalCenter
                            }
                            text: root.sectionLabels[modelData]
                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12
                            color: active ? colors.text : colors.subtext0
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.scrollTo(modelData)
                        }
                    }
                }
            }

            Rectangle {
                width: 1
                height: parent.height
                color: colors.surface1
            }

            Flickable {
                id: scrollArea
                width: parent.width - sidebar.width - 1
                height: parent.height
                contentWidth: width
                contentHeight: content.implicitHeight + 32
                clip: true

                Behavior on contentY {
                    NumberAnimation { duration: tokens.spatialDuration; easing.type: Easing.OutCubic }
                }

                onContentYChanged: {
                    const probe = contentY + 40;
                    let current = root.sectionOrder[0];
                    for (const key of root.sectionOrder) {
                        const item = root.sectionAnchors[key];
                        if (item && (content.y + item.y) <= probe) current = key;
                    }
                    root.activeSection = current;
                }

                Column {
                    id: content
                    x: 16
                    y: 16
                    width: parent.width - 32
                    spacing: 24

                    Column {
                        id: networkAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.network; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        NetworkSettingsSection { width: content.width }
                    }

                    Column {
                        id: audioAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.audio; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        AudioSettingsSection { width: content.width }
                    }

                    Column {
                        id: wallpaperAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.wallpaper; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        WallpaperSettingsSection { id: wallpaperSection; width: content.width }
                    }

                    Column {
                        id: displayAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.display; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        DisplaySettingsSection { width: content.width }
                    }

                    Column {
                        id: clockAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.clock; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        ClockSettingsSection { id: clockSection; width: content.width }
                    }

                    Column {
                        id: aboutAnchor
                        width: content.width
                        spacing: 12
                        Text { text: root.sectionLabels.about; color: colors.text; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 15; font.bold: true }
                        AboutSettingsSection { id: aboutSection; width: content.width }
                    }

                    Component.onCompleted: {
                        root.sectionAnchors = {
                            network: networkAnchor,
                            audio: audioAnchor,
                            wallpaper: wallpaperAnchor,
                            display: displayAnchor,
                            clock: clockAnchor,
                            about: aboutAnchor
                        };
                    }
                }
            }
        }

        Rectangle {
            anchors {
                left: parent.left
                right: parent.right
                bottom: powerBar.top
            }
            height: 1
            color: colors.surface1
        }

        // lock/logout/restart/shutdown — always visible regardless of scroll
        // position. "Log Out" asks Hyprland itself to quit via
        // Hyprland.dispatch() — but since Hyprland 0.55, the "dispatch"
        // socket verb evaluates its argument as a Lua expression that must
        // produce a dispatcher object, not a bare legacy dispatcher name
        // (confirmed: `hyprctl dispatch exit` itself fails with
        // "hl.dispatch: expected a dispatcher", the fix being
        // `hl.dsp.exit()` — same form as the wiki's
        // `hyprctl dispatch 'hl.dsp.submap("reset")'` example).
        // restart/shutdown are plain systemd calls; lock just runs hyprlock
        // directly, same binary the mainMod+L keybind in hyprland.lua
        // already launches.
        Item {
            id: powerBar
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 48

            Process { id: actionProc }
            function run(args) {
                if (actionProc.running) return;
                actionProc.command = args;
                actionProc.running = true;
            }

            Row {
                anchors.centerIn: parent
                spacing: 12

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Lock"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["hyprlock", "--immediate-render"])
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Log Out"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("hl.dsp.exit()")
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.alpha(colors.overlay0, 0.3)

                    Text {
                        anchors.centerIn: parent
                        text: "Restart"
                        color: colors.subtext0
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["systemctl", "reboot"])
                    }
                }

                Rectangle {
                    width: 90
                    height: 28
                    radius: 6
                    color: Qt.alpha(colors.red, 0.12)
                    border.width: 1
                    border.color: Qt.alpha(colors.red, 0.4)

                    Text {
                        anchors.centerIn: parent
                        text: "Shut Down"
                        color: colors.red
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: powerBar.run(["systemctl", "poweroff"])
                    }
                }
            }
        }
    }
}

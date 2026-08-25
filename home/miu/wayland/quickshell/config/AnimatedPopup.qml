import QtQuick
import Quickshell

// Shared "M3-ish" popup scaffold for the bar's hover panels: a fixed-size
// wlr-layer-shell popup window containing an Item whose height animates
// from 0 up to `targetHeight` when open.
//
// NOTE: the window's own implicitHeight must stay fixed — animating a
// wlr-layer-shell popup surface down to 0px height crashed the whole
// quickshell process (which took the bar down with it) when this was first
// built. The "grow" effect below animates a plain Item inside a
// fixed-size window instead.
//
// Open/close is driven by hover on TWO things, both OR'd together:
//   - `iconHovered`, bound by the caller to its own trigger icon's
//     MouseArea.containsMouse
//   - `contentHovered`, tracked internally via a HoverHandler over the
//     popup's own content — this is what previously didn't exist: without
//     it, moving the mouse from the icon into the popup (a different
//     surface, with a real gap between them) crossed a moment where
//     neither area reported hover, so the popup started closing right as
//     you tried to interact with it.
// A short debounce absorbs that gap crossing so a quick icon→popup hop
// doesn't start a close. `visible` is kept true for the full close
// animation via an explicit timer matched to its duration, rather than
// racing the Behavior's `running` property (which could flicker the whole
// window invisible for a frame before the shrink animation caught up).
PopupWindow {
    id: root

    property bool iconHovered: false
    property bool contentHovered: false
    readonly property bool hoveredAny: iconHovered || contentHovered

    property bool open: false
    property real targetHeight: 64
    property Item anchorItem
    property int edges: Edges.Bottom | Edges.Left
    property int gravity: Edges.Bottom | Edges.Right
    default property alias content: card.data

    onHoveredAnyChanged: {
        if (hoveredAny) {
            closeDebounce.stop();
            open = true;
        } else {
            closeDebounce.restart();
        }
    }

    Timer {
        id: closeDebounce
        interval: 150
        onTriggered: root.open = false
    }

    property bool closing: false
    onOpenChanged: {
        if (open) {
            closeVisibleTimer.stop();
            closing = false;
        } else {
            closing = true;
            closeVisibleTimer.restart();
        }
    }

    Timer {
        id: closeVisibleTimer
        interval: tokens.spatialDuration
        onTriggered: root.closing = false
    }

    visible: open || closing

    anchor.item: anchorItem
    anchor.edges: edges
    anchor.gravity: gravity
    // negative bottom margin (not a positive top margin — anchor.margins
    // shrinks the anchor *rect*, and edges:Bottom keys off the rect's
    // bottom edge, so only the bottom margin affects the gap here) pushes
    // the popup 8px clear of the bar below the icon.
    anchor.margins.bottom: -8

    implicitWidth: 260
    implicitHeight: targetHeight
    color: "transparent"

    Colors { id: colors }
    Tokens { id: tokens }

    Item {
        id: reveal
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        clip: true
        height: root.open ? root.targetHeight : 0

        Behavior on height {
            NumberAnimation {
                duration: tokens.spatialDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: tokens.spatialCurve
            }
        }

        Rectangle {
            id: card
            width: parent.width
            height: root.targetHeight
            radius: tokens.roundingNormal
            color: colors.mantle
            border.color: colors.surface1
            border.width: 1

            // passive hover tracking — unlike a MouseArea, HoverHandler
            // doesn't consume input, so clicks/drags on the real content
            // (sliders, list items, buttons) placed here via `content`
            // still work normally underneath it.
            HoverHandler {
                onHoveredChanged: root.contentHovered = hovered
            }
        }
    }
}

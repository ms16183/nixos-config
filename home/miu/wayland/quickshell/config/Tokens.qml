import QtQuick

// shape/spacing scale, matched to vast-shell's AppearanceConfig.qml
QtObject {
    readonly property int roundingSmall: 12
    readonly property int roundingNormal: 17
    readonly property int roundingLarge: 25
    readonly property int roundingFull: 1000

    readonly property int spacingSmall: 7
    readonly property int spacingNormal: 12
    readonly property int spacingLarge: 20

    // motion curves, matched to vast-shell's AppearanceConfig.qml
    // (AnimationCurvesComponent/AnimationDurationsComponent)
    readonly property int spatialDuration: 500
    readonly property var spatialCurve: [0.38, 1.21, 0.22, 1, 1, 1] // expressiveDefaultSpatial

    readonly property int emphasizedDuration: 500
    readonly property var emphasizedCurve: [0.05, 0, 0.13, 0.06, 0.16, 0.4, 0.20833, 0.82, 0.25, 1, 1, 1] // emphasized
}

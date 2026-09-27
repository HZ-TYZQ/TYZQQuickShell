pragma Singleton

import QtQuick
import Quickshell

// Material 3 dark palette seeded from #c3c2f3 (matches the niri focus ring).
Singleton {
    id: root

    readonly property color primary: "#c3c2f3"
    readonly property color fgPrimary: "#2c2b5a"
    readonly property color primaryContainer: "#434272"
    readonly property color fgPrimaryContainer: "#e2dfff"
    readonly property color secondary: "#c7c4dd"
    readonly property color fgSecondary: "#2f2e42"
    readonly property color secondaryContainer: "#46455a"
    readonly property color fgSecondaryContainer: "#e4e0f9"
    readonly property color tertiary: "#eab9d1"
    readonly property color tertiaryContainer: "#613b50"
    readonly property color fgTertiaryContainer: "#ffd8ea"
    readonly property color error: "#ffb4ab"
    readonly property color fgError: "#690005"
    readonly property color errorContainer: "#93000a"
    readonly property color success: "#a8d8a0"

    readonly property color surface: "#131316"
    readonly property color surfaceContainerLowest: "#0e0e11"
    readonly property color surfaceContainerLow: "#1b1b1f"
    readonly property color surfaceContainer: "#1f1f23"
    readonly property color surfaceContainerHigh: "#2a292d"
    readonly property color surfaceContainerHighest: "#353438"
    readonly property color fg: "#e5e1e6"
    readonly property color fgVariant: "#c8c5d0"
    readonly property color outline: "#918f9a"
    readonly property color outlineVariant: "#47464f"
    readonly property color shadow: "#000000"

    // Translucent surfaces; niri blurs what is behind them.
    readonly property color barBg: Qt.alpha(surface, 0.72)
    readonly property color panelBg: Qt.alpha(surfaceContainerLow, 0.86)
    readonly property color layer1: Qt.alpha(surfaceContainerHigh, 0.75)
    readonly property color layer2: Qt.alpha(surfaceContainerHighest, 0.8)

    readonly property string fontSans: "Adwaita Sans"
    readonly property string fontMono: "CaskaydiaCove NFM"
    readonly property string fontIcon: "Material Symbols Rounded"

    readonly property QtObject fontSize: QtObject {
        readonly property int small: 11
        readonly property int normal: 13
        readonly property int large: 15
        readonly property int title: 18
        readonly property int huge: 28
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: 8
        readonly property int normal: 14
        readonly property int large: 22
        readonly property int full: 999
    }

    readonly property int barHeight: 40
    readonly property int gap: 10

    readonly property QtObject anim: QtObject {
        readonly property int fast: 140
        readonly property int normal: 240
        readonly property int slow: 380
        // M3 "emphasized decelerate"
        readonly property list<real> emphasized: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
    }
}

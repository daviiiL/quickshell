pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color primary: "#d0bcff"
    readonly property color fgPrimary: "#381e72"
    readonly property color primaryContainer: "#4f378b"
    readonly property color fgPrimaryContainer: "#eaddff"
    readonly property color primaryFixedDim: "#d0bcff"

    readonly property color secondary: "#ccc2dc"
    readonly property color fgSecondary: "#332d41"
    readonly property color secondaryContainer: "#4a4458"
    readonly property color fgSecondaryContainer: "#e8def8"
    readonly property color secondaryFixedDim: "#ccc2dc"

    readonly property color tertiary: "#efb8c8"
    readonly property color fgTertiary: "#492532"
    readonly property color tertiaryContainer: "#633b48"
    readonly property color fgTertiaryContainer: "#ffd8e4"

    readonly property color error: "#f2b8b5"
    readonly property color fgError: "#601410"
    readonly property color errorContainer: "#8c1d18"
    readonly property color fgErrorContainer: "#f9dedc"

    readonly property color background: "#141218"
    readonly property color fgBackground: "#e6e0e9"
    readonly property color surface: "#141218"
    readonly property color fgSurface: "#e6e0e9"
    readonly property color surfaceVariant: "#49454f"
    readonly property color fgSurfaceVariant: "#cac4d0"
    readonly property color surfaceDim: "#141218"
    readonly property color surfaceBright: "#3b383e"
    readonly property color surfaceContainerLowest: "#0f0d13"
    readonly property color surfaceContainerLow: "#1d1b20"
    readonly property color surfaceContainer: "#211f26"
    readonly property color surfaceContainerHigh: "#2b2930"
    readonly property color surfaceContainerHighest: "#36343b"

    readonly property color outline: "#938f99"
    readonly property color outlineVariant: "#49454f"
    readonly property color scrim: "#000000"
    readonly property color shadow: "#000000"

    readonly property color inversePrimary: "#6750a4"
    readonly property color inverseSurface: "#e6e0e9"
    readonly property color inverseOnSurface: "#322f35"

    readonly property color surfaceLight: Qt.lighter(root.surface, 1)
    readonly property color surfaceLightTranslucent: Qt.rgba(surfaceLight.r, surfaceLight.g, surfaceLight.b, 0.9)
    readonly property color surfaceTranslucent: Qt.rgba(surface.r, surface.g, surface.b, 0.96)

    readonly property color success: "#4a9d4a"
    readonly property color warning: "#ffd4ab"

    readonly property color panelBg:    "#0f0f13"
    readonly property color barBg:      "#0a0a0a"
    readonly property color hair:       "#272727"
    readonly property color hairHot:    "#3a3a3a"
    readonly property color inkDim:     "#8f8f8f"
    readonly property color inkDimmer:  "#6b6b6b"
    readonly property color inkFaint:   "#4d4d4d"
    readonly property color barAccent:  "#e3e3e3"
    readonly property color live:       "#5dc70a"
    readonly property color scanning:   "#f59e0b"
}

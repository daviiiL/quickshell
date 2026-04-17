pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    // Material Design 3 baseline dark palette. Hardcoded; no matugen, no colors.json.
    readonly property color primary: "#d0bcff"
    readonly property color onPrimary: "#381e72"
    readonly property color primaryContainer: "#4f378b"
    readonly property color onPrimaryContainer: "#eaddff"
    readonly property color primaryFixedDim: "#d0bcff"

    readonly property color secondary: "#ccc2dc"
    readonly property color onSecondary: "#332d41"
    readonly property color secondaryContainer: "#4a4458"
    readonly property color onSecondaryContainer: "#e8def8"
    readonly property color secondaryFixedDim: "#ccc2dc"

    readonly property color tertiary: "#efb8c8"
    readonly property color onTertiary: "#492532"
    readonly property color tertiaryContainer: "#633b48"
    readonly property color onTertiaryContainer: "#ffd8e4"

    readonly property color error: "#f2b8b5"
    readonly property color onError: "#601410"
    readonly property color errorContainer: "#8c1d18"
    readonly property color onErrorContainer: "#f9dedc"

    readonly property color background: "#141218"
    readonly property color onBackground: "#e6e0e9"
    readonly property color surface: "#141218"
    readonly property color onSurface: "#e6e0e9"
    readonly property color surfaceVariant: "#49454f"
    readonly property color onSurfaceVariant: "#cac4d0"
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

    // Derived / translucent helpers
    readonly property color surfaceLight: Qt.lighter(root.surface, 1)
    readonly property color surfaceLightTranslucent: Qt.rgba(surfaceLight.r, surfaceLight.g, surfaceLight.b, 0.9)
    readonly property color surfaceTranslucent: Qt.rgba(surface.r, surface.g, surface.b, 0.96)

    // Semantic status colors
    readonly property color success: "#4a9d4a"
    readonly property color warning: "#ffd4ab"
}

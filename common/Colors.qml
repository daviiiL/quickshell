pragma Singleton

import QtQuick
import Quickshell
import qs.common

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
    property color surface:                 GlobalStates.darkMode ? "#141218" : "#f5f2f7"
    property color fgSurface:               GlobalStates.darkMode ? "#e6e0e9" : "#1c1820"
    readonly property color surfaceVariant: "#49454f"
    readonly property color fgSurfaceVariant: "#cac4d0"
    readonly property color surfaceDim: "#141218"
    readonly property color surfaceBright: "#3b383e"
    property color surfaceContainerLowest:  GlobalStates.darkMode ? "#0f0d13" : "#fbf9fc"
    property color surfaceContainerLow:     GlobalStates.darkMode ? "#1d1b20" : "#eee9f0"
    property color surfaceContainer:        GlobalStates.darkMode ? "#211f26" : "#e3dee6"
    property color surfaceContainerHigh:    GlobalStates.darkMode ? "#2b2930" : "#d4cfd9"
    readonly property color surfaceContainerHighest: "#36343b"

    Behavior on surface                 { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on fgSurface               { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerLowest  { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerLow     { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainer        { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerHigh    { ColorAnimation { duration: Theme.anim.durations.sm } }

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
    property color warning:    GlobalStates.darkMode ? "#ffd4ab" : "#a65a1c"

    property color panelBg:    GlobalStates.darkMode ? "#0f0f13" : "#f5f2f7"
    property color barBg:      GlobalStates.darkMode ? "#0a0a0a" : "#e4e0e9"
    property color hair:       GlobalStates.darkMode ? "#272727" : "#d6d1dc"
    property color hairHot:    GlobalStates.darkMode ? "#3a3a3a" : "#bcb7c2"
    property color inkDim:     GlobalStates.darkMode ? "#8f8f8f" : "#5b5764"
    property color inkDimmer:  GlobalStates.darkMode ? "#6b6b6b" : "#827e8a"
    property color inkFaint:   GlobalStates.darkMode ? "#4d4d4d" : "#a8a4b0"
    property color barAccent:  GlobalStates.darkMode ? "#e3e3e3" : "#1c1820"
    property color live:       GlobalStates.darkMode ? "#5dc70a" : "#3d8f0a"
    property color scanning:   GlobalStates.darkMode ? "#f59e0b" : "#a85d0a"

    Behavior on warning   { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on panelBg   { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on barBg     { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on hair      { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on hairHot   { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on inkDim    { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on inkDimmer { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on inkFaint  { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on barAccent { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on live      { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on scanning  { ColorAnimation { duration: Theme.anim.durations.sm } }
}

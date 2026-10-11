pragma Singleton

import QtQuick
import Quickshell
import qs.common

Singleton {
    id: root

    readonly property color primary:            GlobalStates.darkMode ? "#d0bcff" : "#6750a4"
    readonly property color fgPrimary:          GlobalStates.darkMode ? "#381e72" : "#ffffff"
    readonly property color primaryContainer:   GlobalStates.darkMode ? "#4f378b" : "#eaddff"
    readonly property color fgPrimaryContainer: GlobalStates.darkMode ? "#eaddff" : "#21005d"

    readonly property color secondary:            GlobalStates.darkMode ? "#ccc2dc" : "#625b71"
    readonly property color fgSecondary:          GlobalStates.darkMode ? "#332d41" : "#ffffff"
    readonly property color secondaryContainer:   GlobalStates.darkMode ? "#4a4458" : "#e8def8"
    readonly property color fgSecondaryContainer: GlobalStates.darkMode ? "#e8def8" : "#1d192b"

    readonly property color tertiary:            GlobalStates.darkMode ? "#efb8c8" : "#7d5260"
    readonly property color fgTertiary:          GlobalStates.darkMode ? "#492532" : "#ffffff"
    readonly property color tertiaryContainer:   GlobalStates.darkMode ? "#633b48" : "#ffd8e4"
    readonly property color fgTertiaryContainer: GlobalStates.darkMode ? "#ffd8e4" : "#31111d"

    readonly property color error:            GlobalStates.darkMode ? "#f2b8b5" : "#b3261e"
    readonly property color fgError:          GlobalStates.darkMode ? "#601410" : "#ffffff"
    readonly property color errorContainer:   GlobalStates.darkMode ? "#8c1d18" : "#f9dedc"
    readonly property color fgErrorContainer: GlobalStates.darkMode ? "#f9dedc" : "#410e0b"

    property color surface:                 GlobalStates.darkMode ? "#141218" : "#f5f2f7"
    property color fgSurface:               GlobalStates.darkMode ? "#e6e0e9" : "#1c1820"
    readonly property color surfaceVariant:   GlobalStates.darkMode ? "#49454f" : "#e7e0ec"
    readonly property color fgSurfaceVariant: GlobalStates.darkMode ? "#cac4d0" : "#49454f"
    property color surfaceContainerLowest:  GlobalStates.darkMode ? "#0f0d13" : "#fbf9fc"
    property color surfaceContainerLow:     GlobalStates.darkMode ? "#1d1b20" : "#eee9f0"
    property color surfaceContainer:        GlobalStates.darkMode ? "#211f26" : "#e3dee6"
    property color surfaceContainerHigh:    GlobalStates.darkMode ? "#2b2930" : "#d4cfd9"

    Behavior on surface                 { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on fgSurface               { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerLowest  { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerLow     { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainer        { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on surfaceContainerHigh    { ColorAnimation { duration: Theme.anim.durations.sm } }

    readonly property color outline:        GlobalStates.darkMode ? "#938f99" : "#79747e"
    readonly property color outlineVariant: GlobalStates.darkMode ? "#49454f" : "#cac4d0"
    readonly property color scrim: "#000000"
    readonly property color shadow: "#000000"

    readonly property color success: "#4a9d4a"
    property color warning:    GlobalStates.darkMode ? "#ffd4ab" : "#a65a1c"

    property color panelBg:    GlobalStates.darkMode ? "#0f0f13" : "#f5f2f7"
    property color barBg:      GlobalStates.darkMode ? "#0a0a0a" : "#e4e0e9"
    property color hair:       GlobalStates.darkMode ? "#272727" : "#c5bfcc"
    property color hairHot:    GlobalStates.darkMode ? "#3a3a3a" : "#a59fad"
    property color inkDim:     GlobalStates.darkMode ? "#8f8f8f" : "#5b5764"
    property color inkDimmer:  GlobalStates.darkMode ? "#6b6b6b" : "#6e6977"
    property color inkFaint:   GlobalStates.darkMode ? "#4d4d4d" : "#8d8896"
    property color barAccent:  GlobalStates.darkMode ? "#e3e3e3" : "#1c1820"
    property color live:       GlobalStates.darkMode ? "#5dc70a" : "#3d8f0a"
    property color busy:       GlobalStates.darkMode ? "#fac028" : "#b8860b"
    property color stale:      GlobalStates.darkMode ? "#f59e0b" : "#a85d0a"
    property color hairCatch:  GlobalStates.darkMode ? Qt.rgba(0.89, 0.89, 0.89, 0.55) : Qt.rgba(0.11, 0.094, 0.125, 0.42)
    readonly property color criticalHalo:     GlobalStates.darkMode ? Qt.rgba(0.949, 0.722, 0.710, 0.35) : Qt.rgba(0.702, 0.149, 0.118, 0.30)
    readonly property color criticalChipFill: GlobalStates.darkMode ? Qt.rgba(0.949, 0.722, 0.710, 0.06) : Qt.rgba(0.702, 0.149, 0.118, 0.06)

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
    Behavior on busy      { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on stale     { ColorAnimation { duration: Theme.anim.durations.sm } }
    Behavior on hairCatch { ColorAnimation { duration: Theme.anim.durations.sm } }
}

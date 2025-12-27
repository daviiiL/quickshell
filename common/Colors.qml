pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property Colorscheme current: Colorscheme {}

    readonly property color background: current.background
    readonly property color error: current.error
    readonly property color error_container: current.error_container
    readonly property color inverse_on_surface: current.inverse_on_surface
    readonly property color inverse_primary: current.inverse_primary
    readonly property color inverse_surface: current.inverse_surface
    readonly property color on_background: current.on_background
    readonly property color on_error: current.on_error
    readonly property color on_error_container: current.on_error_container
    readonly property color on_primary: current.on_primary
    readonly property color on_primary_container: current.on_primary_container
    readonly property color on_primary_fixed: current.on_primary_fixed
    readonly property color on_primary_fixed_variant: current.on_primary_fixed_variant
    readonly property color on_secondary: current.on_secondary
    readonly property color on_secondary_container: current.on_secondary_container
    readonly property color on_secondary_fixed: current.on_secondary_fixed
    readonly property color on_secondary_fixed_variant: current.on_secondary_fixed_variant
    readonly property color on_surface: current.on_surface
    readonly property color on_surface_variant: current.on_surface_variant
    readonly property color on_tertiary: current.on_tertiary
    readonly property color on_tertiary_container: current.on_tertiary_container
    readonly property color on_tertiary_fixed: current.on_tertiary_fixed
    readonly property color on_tertiary_fixed_variant: current.on_tertiary_fixed_variant
    readonly property color outline: current.outline
    readonly property color outline_variant: current.outline_variant
    readonly property color primary: current.primary
    readonly property color primary_container: current.primary_container
    readonly property color primary_fixed: current.primary_fixed
    readonly property color primary_fixed_dim: current.primary_fixed_dim
    readonly property color scrim: current.scrim
    readonly property color secondary: current.secondary
    readonly property color secondary_container: current.secondary_container
    readonly property color secondary_fixed: current.secondary_fixed
    readonly property color secondary_fixed_dim: current.secondary_fixed_dim
    readonly property color shadow: current.shadow
    readonly property color source_color: current.source_color
    readonly property color surface: current.surface
    readonly property color surface_bright: current.surface_bright
    readonly property color surface_container: current.surface_container
    readonly property color surface_container_high: current.surface_container_high
    readonly property color surface_container_highest: current.surface_container_highest
    readonly property color surface_container_low: current.surface_container_low
    readonly property color surface_container_lowest: current.surface_container_lowest
    readonly property color surface_dim: current.surface_dim
    readonly property color surface_tint: current.surface_tint
    readonly property color surface_variant: current.surface_variant
    readonly property color tertiary: current.tertiary
    readonly property color tertiary_container: current.tertiary_container
    readonly property color tertiary_fixed: current.tertiary_fixed
    readonly property color tertiary_fixed_dim: current.tertiary_fixed_dim

    readonly property color surface_light: Qt.lighter(root.surface, 1)
    readonly property color surface_light_translucent: Qt.rgba(surface_light.r, surface_light.g, surface_light.b, 0.9)

    function load(data: string): void {
        const obj = JSON.parse(data);

        for (const [key, value] of Object.entries(obj)) {
            if (current.hasOwnProperty(key)) {
                if (key === "background") {
                    current[key] = "#000000";
                } else {
                    current[key] = value;
                }
            }
        }
    }

    FileView {
        id: jsonData
        path: Qt.resolvedUrl("../colors.json")
        preload: true
        blockLoading: true
        watchChanges: true
        onFileChanged: this.reload()
        onLoaded: root.load(this.text())
    }

    function hexToQtRgba(hex, alpha = 1.0) {
        hex = hex.toString().replace(/^#/, '');

        if (hex.length === 3) {
            hex = hex.split('').map(c => c + c).join('');
        }

        if (hex.length !== 6) {
            throw new Error("Invalid hex color format");
        }

        const r = parseInt(hex.slice(0, 2), 16) / 256;
        const g = parseInt(hex.slice(2, 4), 16) / 256;
        const b = parseInt(hex.slice(4, 6), 16) / 256;

        return Qt.rgba(r, g, b, 1);
    }

    component Colorscheme: QtObject {
        property color background
        property color error
        property color error_container
        property color inverse_on_surface
        property color inverse_primary
        property color inverse_surface
        property color on_background
        property color on_error
        property color on_error_container
        property color on_primary
        property color on_primary_container
        property color on_primary_fixed
        property color on_primary_fixed_variant
        property color on_secondary
        property color on_secondary_container
        property color on_secondary_fixed
        property color on_secondary_fixed_variant
        property color on_surface
        property color on_surface_variant
        property color on_tertiary
        property color on_tertiary_container
        property color on_tertiary_fixed
        property color on_tertiary_fixed_variant
        property color outline
        property color outline_variant
        property color primary
        property color primary_container
        property color primary_fixed
        property color primary_fixed_dim
        property color scrim
        property color secondary
        property color secondary_container
        property color secondary_fixed
        property color secondary_fixed_dim
        property color shadow
        property color source_color
        property color surface
        property color surface_bright
        property color surface_container
        property color surface_container_high
        property color surface_container_highest
        property color surface_container_low
        property color surface_container_lowest
        property color surface_dim
        property color surface_tint
        property color surface_variant
        property color tertiary
        property color tertiary_container
        property color tertiary_fixed
        property color tertiary_fixed_dim
    }
}

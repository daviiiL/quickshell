pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property Colorscheme current: Colorscheme {}

    function load(data: string): void {
        const obj = JSON.parse(data);

        for (const [key, value] of Object.entries(obj)) {
            if (current.hasOwnProperty(key)) {
                if (key === "background") {
                    current[key] = "#000000";
                } else
                    current[key] = value;
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

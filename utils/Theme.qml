pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property Font font: Font {}
    readonly property Rounding rounding: Rounding {}
    readonly property Anim anim: Anim {}
    readonly property Bar bar: Bar {}

    component Bar: QtObject {
        readonly property int width: 50
        readonly property int maxWidth: this.width * 4
    }

    component Font: QtObject {
        readonly property FontSize size: FontSize {}
        readonly property FontStyle style: FontStyle {}
    }

    component FontSize: QtObject {
        readonly property int small: 9
        readonly property int regular: 11
        readonly property int large: 18
        readonly property int larger: 24
    }

    component FontStyle: QtObject {
        readonly property string inter_thin: "Inter Nerd Font Propo Thin"
        readonly property string inter: "Inter Nerd Font Propo"
        readonly property string inter_bold: "Inter Nerd Font Propo:style=Bold"
        readonly property string material: "Material Symbols Rounded"
        readonly property string free_mono: "FreeMono"
    }

    component Rounding: QtObject {
        readonly property int small: 3
        readonly property int regular: 8
        readonly property int large: 15
    }

    component AnimCurves: QtObject {
        readonly property list<real> emphasized: [0.05, 0, 2 / 15, 0.06, 1 / 6, 0.4, 5 / 24, 0.82, 0.25, 1, 1, 1]
        readonly property list<real> emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
        readonly property list<real> emphasizedDecel: [0.05, 0.7, 0.1, 1, 1, 1]
        readonly property list<real> standard: [0.2, 0, 0, 1, 1, 1]
        readonly property list<real> standardAccel: [0.3, 0, 1, 1, 1, 1]
        readonly property list<real> standardDecel: [0, 0, 0, 1, 1, 1]
        readonly property list<real> expressiveFastSpatial: [0.42, 1.67, 0.21, 0.9, 1, 1]
        readonly property list<real> expressiveDefaultSpatial: [0.38, 1.21, 0.22, 1, 1, 1]
        readonly property list<real> expressiveEffects: [0.34, 0.8, 0.34, 1, 1, 1]
    }

    component AnimDurations: QtObject {
        readonly property int small: 200
        readonly property int normal: 400
        readonly property int large: 600
        readonly property int extraLarge: 1000
        readonly property int expressiveFastSpatial: 350
        readonly property int expressiveDefaultSpatial: 500
        readonly property int expressiveEffects: 200
    }

    component Anim: QtObject {
        readonly property AnimCurves curves: AnimCurves {}
        readonly property AnimDurations durations: AnimDurations {}
    }
}

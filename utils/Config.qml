pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property Font font: Font {}
    readonly property Rounding rounding: Rounding {}
    readonly property Bar bar: Bar {}

    component Bar: QtObject {
        readonly property int width: 50
    }

    component Font: QtObject {
        readonly property FontSize size: FontSize {}
        readonly property FontStyle style: FontStyle {}
    }

    component FontSize: QtObject {
        readonly property int small: 9
        readonly property int regular: 12
        readonly property int large: 18
        readonly property int larger: 24
    }

    component FontStyle: QtObject {
        readonly property string inter_thin: "Inter Nerd Font Propo Thin"
        readonly property string inter: "Inter Nerd Font Propo"
        readonly property string inter_bold: "Inter Nerd Font Propo:style=Bold"
    }

    component Rounding: QtObject {
        readonly property int small: 3
        readonly property int regular: 8
        readonly property int large: 15
    }
}

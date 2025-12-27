pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property ThemeFont font: ThemeFont {}
    readonly property ThemeStyle ui: ThemeStyle {}
    readonly property ThemeAnimation anim: ThemeAnimation {}

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
        readonly property int xs: 200
        readonly property int sm: 400
        readonly property int md: 600
        readonly property int lg: 1000
        readonly property int xl: 1500
        readonly property int expressiveFastSpatial: 350
        readonly property int expressiveDefaultSpatial: 500
        readonly property int expressiveEffects: 200
    }

    component ThemeAnimation: QtObject {
        readonly property AnimCurves curves: AnimCurves {}
        readonly property AnimDurations durations: AnimDurations {}
    }

    component ThemeFont: QtObject {
        readonly property FontFamily family: FontFamily {}
        readonly property FontSize size: FontSize {}
    }

    component ThemeStyle: QtObject {
        readonly property ThemeRadius radius: ThemeRadius {}
        readonly property ThemeElevation elevation: ThemeElevation {}
        readonly property ThemePadding padding: ThemePadding {}
        readonly property int topBarHeight: 48
        readonly property int leftBarWidth: 86
        readonly property int borderWidth: 1
        readonly property int iconSize: 24
    }

    component ThemeRadius: QtObject {
        readonly property int sm: 4
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
    }

    component ThemeElevation: QtObject {
        readonly property int card: 2
        readonly property int dialog: 24
        readonly property int fab: 6
        readonly property int input: 1
        readonly property int menu: 8
        readonly property int snackbar: 6
        readonly property int tooltip: 8
    }

    component ThemePadding: QtObject {
        readonly property int sm: 8
        readonly property int md: 16
        readonly property int lg: 24
    }

    component FontFamily: QtObject {
        readonly property string departureMono: "DepartureMono Nerd Font"
        readonly property string inter_extra_bold_italic: "Inter Extra Bold Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Extra Bold:style=Extra Bold Italic,Italic"
        readonly property string inter_light: "Inter Light Nerd Font Complete.otf: Inter Nerd Font,Inter Light:style=Light,Regular"
        readonly property string inter_thin: "Inter Thin Nerd Font Complete.otf: Inter Nerd Font,Inter Thin:style=Thin,Regular"
        readonly property string inter_medium_italic: "Inter Medium Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Medium:style=Medium Italic,Italic"
        readonly property string inter_black: "Inter Black Nerd Font Complete.otf: Inter Nerd Font,Inter Black:style=Black,Regular"
        readonly property string inter_bold_italic: "Inter Bold Italic Nerd Font Complete.otf: Inter Nerd Font:style=Bold Italic"
        readonly property string inter_thin_italic: "Inter Thin Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Thin:style=Thin Italic,Italic"
        readonly property string inter_regular: "Inter Regular Nerd Font Complete.otf: Inter Nerd Font:style=Regular"
        readonly property string inter_italic: "Inter Italic Nerd Font Complete.otf: Inter Nerd Font:style=Italic"
        readonly property string inter_extra_bold: "Inter Extra Bold Nerd Font Complete.otf: Inter Nerd Font,Inter Extra Bold:style=Extra Bold,Regular"
        readonly property string inter_bold: "Inter Bold Nerd Font Complete.otf: Inter Nerd Font:style=Bold"
        readonly property string inter_extra_light_italic: "Inter Extra Light Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Extra Light:style=Extra Light Italic,Italic"
        readonly property string inter_semi_bold_italic: "Inter Semi Bold Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Semi Bold:style=Semi Bold Italic,Italic"
        readonly property string inter_medium: "Inter Medium Nerd Font Complete.otf: Inter Nerd Font,Inter Medium:style=Medium,Regular"
        readonly property string inter_black_italic: "Inter Black Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Black:style=Black Italic,Italic"
        readonly property string inter_extra_light: "Inter Extra Light Nerd Font Complete.otf: Inter Nerd Font,Inter Extra Light:style=Extra Light,Regular"
        readonly property string inter_light_italic: "Inter Light Italic Nerd Font Complete.otf: Inter Nerd Font,Inter Light:style=Light Italic,Italic"
        readonly property string inter_semi_bold: "Inter Semi Bold Nerd Font Complete.otf: Inter Nerd Font,Inter Semi Bold:style=Semi Bold,Regular"
    }

    component FontSize: QtObject {
        readonly property int xxs: 8
        readonly property int xs: 10
        readonly property int sm: 12
        readonly property int md: 14
        readonly property int lg: 16
        readonly property int xl: 20
        readonly property int xxl: 24
        readonly property int xxxl: 32
    }
}

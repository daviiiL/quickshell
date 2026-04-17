pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 0

    readonly property real level: Brightness.available ? Brightness.brightness : 72
    readonly property string iconKey: {
        const frac = root.level / 100;
        if (frac < 0.15) return "brightness_low";
        if (frac < 0.55) return "brightness_medium";
        return "brightness_high";
    }

    SectionHead {
        title: "display"
        meta: Brightness.available ? Brightness._backlightDevice : "primary"
    }

    SliderRow {
        Layout.bottomMargin: 14
        value: root.level
        from: 0
        to: 100
        valueLabel: Math.round(root.level) + "%"

        onMoved: v => {
            if (Brightness.available) Brightness.setBrightness(v);
        }

        iconSource: {
            const frac = root.level / 100;
            const base = "../../assets/icons/";
            if (frac < 0.15) return base + "brightness-1.svg";
            if (frac < 0.55) return base + "brightness-2.svg";
            return base + "brightness-3.svg";
        }
    }
}

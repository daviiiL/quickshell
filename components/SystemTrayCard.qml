import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common
import qs.components.tray

RectWidgetCard {
    showTitle: true
    title: "Tray"

    Tray {
        anchors.fill: parent
    }
}

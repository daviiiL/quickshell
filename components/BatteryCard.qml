import QtQuick
import QtQuick.Layouts
import qs.widgets
import qs.common
import qs.services

RectWidgetCard {
    showTitle: true
    title: "Battery"
    visible: Power.isLaptopBattery || false

    ColumnLayout {
        spacing: 5
        width: parent.width

        Text {
            text: `BAT ${Math.floor(Power.percentage * 100)}%`
            font.family: Theme.font.family.inter_regular
            font.pixelSize: Theme.font.size.xs
            color: Colors.primary
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: 5
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }

        BatteryProgressBar {
            id: progressBar
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            value: Power.percentage
            total: 1
            charging: Power.isCharging
        }

        Text {
            text: Power.batteryStatusText
            font.family: Theme.font.family.inter_regular
            font.pixelSize: Theme.font.size.xs
            color: Colors.primary
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.bottomMargin: 5
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
}

import QtQuick
import qs.common
import qs.services
import qs.widgets

RectWidgetCard {
    showTitle: true
    title: "Clock"
    Rectangle {
        width: parent.width
        height: hh.height + mm.height + dd.height + 5
        implicitHeight: height
        color: "transparent"

        Text {
            id: hh
            text: DateTime.hrs
            height: 30
            font {
                family: "Inter Nerd Font"
                pixelSize: Theme.font.size.xxxl
                bold: false
            }
            color: Colors.secondary
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.QtRendering
            renderTypeQuality: Text.HighRenderTypeQuality
        }

        Text {
            id: mm
            text: DateTime.mins
            font {
                family: "Inter Nerd Font"
                pixelSize: Theme.font.size.xxxl
                bold: true
            }
            height: 30
            color: Colors.primary
            horizontalAlignment: Text.AlignHCenter
            anchors.top: hh.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            renderType: Text.QtRendering
            renderTypeQuality: Text.HighRenderTypeQuality
        }

        Text {
            id: dd
            text: DateTime.date
            color: Colors.secondary
            font {
                family: "Inter Nerd Font"
                pixelSize: Theme.font.size.sm
                bold: false
            }
            anchors {
                top: mm.bottom
                topMargin: 5
                horizontalCenter: parent.horizontalCenter
            }
            renderType: Text.QtRendering
            renderTypeQuality: Text.HighRenderTypeQuality
        }
    }
}

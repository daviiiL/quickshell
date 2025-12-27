pragma ComponentBehavior: Bound

import QtQuick

import qs.common

Rectangle {
    id: itemRoot
    height: 50
    width: parent.width
    color: "transparent"

    required property int index
    required property string title
    required property int currentIndex

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true

        onPressed: () => {
            ListView.view.currentIndex = itemRoot.index;
        }
    }

    Rectangle {
        anchors.fill: parent
        // anchors {
        //     topMargin: Theme.ui.padding.sm
        //     bottomMargin: Theme.ui.padding.sm
        // }
        radius: Theme.ui.radius.md
        property color highlightBg: Colors.primary_container

        property color targetBgColor: parent.currentIndex === parent.index ? Qt.rgba(highlightBg.r, highlightBg.g, highlightBg.b, 0.3) : "transparent"
        color: targetBgColor

        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.Bezier
                easing.bezierCurve: Theme.anim.curves.emphasized
            }
        }

        Text {
            text: itemRoot.title
            anchors.centerIn: parent
            font {
                pixelSize: Theme.font.size.lg
                family: Theme.font.family.inter_regular
                // bold: itemRoot.index === itemRoot.currentIndex
                weight: itemRoot.index === itemRoot.currentIndex ? Font.Bold : Font.Normal
            }

            Behavior on font.weight {
                NumberAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }

            property color targetTextColor: itemRoot.currentIndex === itemRoot.index ? Colors.on_primary_container : Colors.on_surface
            color: targetTextColor

            Behavior on color {
                ColorAnimation {
                    duration: Theme.anim.durations.sm
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.anim.curves.emphasized
                }
            }
        }
    }
}

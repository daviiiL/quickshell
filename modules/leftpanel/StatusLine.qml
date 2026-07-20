pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    implicitHeight: 40
    color: "transparent"

    readonly property color stColor: {
        switch (Gemini.state) {
        case "idle":
            return Colors.live;
        case "connecting":
            return Colors.warning;
        case "thinking":
        case "responding":
            return Colors.primary;
        case "offline":
            return Colors.error;
        case "needs-key":
            return Colors.warning;
        default:
            return Colors.inkFaint;
        }
    }
    readonly property string stLabel: {
        switch (Gemini.state) {
        case "idle":
            return "online";
        case "connecting":
            return "connecting";
        case "thinking":
            return "thinking";
        case "responding":
            return "responding";
        case "offline":
            return "offline";
        case "needs-key":
            return "no api key";
        default:
            return Gemini.state;
        }
    }

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: Theme.ui.mainBarHairWidth
        color: Colors.hair
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        spacing: 10

        Text {
            text: "GEMINI"
            color: Colors.fgSurface
            font.family: Theme.font.family.inter_medium
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 2.0
            font.weight: Font.Medium
        }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            width: 7
            height: 7
            radius: 3.5
            color: root.stColor
        }

        Text {
            text: root.stLabel
            color: Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 1.6
            font.capitalization: Font.AllUppercase
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: Preferences.geminiModel
            color: Colors.inkFaint
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.xs
            font.letterSpacing: 0.6
        }

        Text {
            text: Gemini.ping > 0 ? Gemini.ping + " ms" : "—"
            color: Colors.inkDim
            font.family: Theme.font.family.inter
            font.pixelSize: Theme.font.size.xs
        }
    }
}

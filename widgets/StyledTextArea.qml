import QtQuick
import QtQuick.Controls
import qs.common

Rectangle {
    id: root

    property alias text: area.text
    property alias placeholderText: area.placeholderText
    property alias textArea: area
    property int maxHeight: 132
    property int baseHeight: 38

    property color focusedBgColor: Colors.surfaceContainer
    property color unfocusedBgColor: Colors.surfaceContainerLow

    signal submitted()

    implicitHeight: Math.min(baseHeight + Math.max(0, area.lineCount - 1) * fm.height, maxHeight)
    radius: Theme.ui.radius.md
    color: Qt.alpha(area.activeFocus ? focusedBgColor : unfocusedBgColor, 0.4)
    border.width: Theme.ui.mainBarHairWidth
    border.color: area.activeFocus ? focusedBgColor : unfocusedBgColor

    FontMetrics { id: fm; font: area.font }

    Flickable {
        id: flick
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        TextArea.flickable: TextArea {
            id: area
            wrapMode: TextArea.Wrap
            color: Colors.fgSurface
            placeholderTextColor: Colors.inkFaint
            selectionColor: root.focusedBgColor
            selectedTextColor: Colors.fgSurface
            topPadding: Math.max(2, (root.baseHeight - fm.height) / 2)
            bottomPadding: topPadding
            leftPadding: 12
            rightPadding: 12
            background: null

            font {
                family: Theme.font.family.inter_thin
                pixelSize: Theme.font.size.sm
            }

            Keys.onPressed: event => {
                if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter) && !(event.modifiers & Qt.ShiftModifier)) {
                    event.accepted = true;
                    root.submitted();
                }
            }
        }

        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
    }
}

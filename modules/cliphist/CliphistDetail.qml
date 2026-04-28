pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

Item {
    id: root

    required property var entry
    required property string decodedText
    required property string query

    signal picked()
    signal deleted()

    Rectangle {
        anchors.fill: parent
        color: Colors.surfaceContainerLowest
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 18
        anchors.topMargin: 12
        anchors.bottomMargin: 14
        spacing: 8
        visible: !!root.entry

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: {
                    const t = (root.entry?.type ?? "TXT").toUpperCase();
                    const len = root.decodedText
                        ? root.decodedText.length
                        : (root.entry?.preview?.length ?? 0);
                    return `${t} · ${len} CHARS`;
                }
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 9
                font.letterSpacing: 1.71
            }

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }

            Text {
                Layout.alignment: Qt.AlignVCenter
                text: root.entry ? "#" + root.entry.id : ""
                color: Colors.inkDimmer
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 9
                font.letterSpacing: 1.71
            }
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: bodyText.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: bodyText.implicitHeight > height

            Text {
                id: bodyText
                width: parent.width
                text: {
                    if (root.entry?.type === "img") return "[binary content]";
                    if (root.decodedText.length === 0) return "DECODING…";
                    return StringUtils.highlightSubstring(root.decodedText, root.query, Colors.warning);
                }
                textFormat: Text.StyledText
                color: Colors.fgSurface
                font.family: "JetBrains Mono"
                font.pixelSize: 12
                lineHeight: 1.5
                wrapMode: Text.WrapAnywhere
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            ActionChip {
                icon: "content_copy"
                label: "COPY"
                onClicked: root.picked()
            }

            ActionChip {
                icon: "delete"
                label: "DELETE"
                danger: true
                onClicked: root.deleted()
            }

            Item { Layout.fillWidth: true; Layout.preferredHeight: 1 }
        }
    }

    component ActionChip: Rectangle {
        id: chip
        property string icon
        property string label
        property bool danger: false
        signal clicked()

        Layout.preferredHeight: 24
        implicitWidth: chipRow.implicitWidth + 18
        radius: Theme.ui.radius.sm
        color: chipMouse.containsMouse ? Colors.surfaceContainerLow : "transparent"
        border.width: 1
        border.color: chip.danger && chipMouse.containsMouse
            ? Colors.error
            : (chipMouse.containsMouse ? Colors.hairHot : Colors.hair)

        Behavior on color        { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6

            MaterialSymbol {
                icon: chip.icon
                iconSize: 12
                fontColor: chip.danger && chipMouse.containsMouse
                    ? Colors.error
                    : (chipMouse.containsMouse ? Colors.fgSurface : Colors.inkDim)
                colorAnimated: true
            }

            Text {
                text: chip.label
                color: chip.danger && chipMouse.containsMouse
                    ? Colors.error
                    : (chipMouse.containsMouse ? Colors.fgSurface : Colors.inkDim)
                font.family: Theme.font.family.inter_medium
                font.pixelSize: 10
                font.letterSpacing: 1.6
            }
        }

        MouseArea {
            id: chipMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: chip.clicked()
        }
    }
}

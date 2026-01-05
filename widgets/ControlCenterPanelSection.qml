import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

ColumnLayout {
    id: root

    required property string title
    required property bool checked

    signal toggled

    property bool showConnectionCard: false
    property string connectionIcon: "wifi"
    property string connectionTitle: ""
    property string connectionSubtitle: ""

    property int topMargin: 0
    default property alias content: contentArea.data

    Layout.fillWidth: true
    Layout.topMargin: root.topMargin
    spacing: Theme.ui.padding.sm

    RowLayout {
        Layout.fillWidth: true
        spacing: Theme.ui.padding.md

        Text {
            text: root.title
            font {
                pixelSize: Theme.font.size.xxl
                family: Theme.font.family.inter_bold
                weight: Font.Bold
            }
            color: Colors.on_surface
        }

        Item {
            Layout.fillWidth: true
        }

        StyledSwitchButton {
            checked: root.checked
            onClicked: root.toggled()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 60
        visible: root.showConnectionCard
        color: Colors.surface_container_high
        radius: Theme.ui.radius.md

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.ui.padding.md
            anchors.rightMargin: Theme.ui.padding.md
            spacing: Theme.ui.padding.md

            MaterialSymbol {
                icon: root.connectionIcon
                iconSize: Theme.font.size.xxl
                fontColor: Colors.primary
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Text {
                    Layout.alignment: Qt.AlignVCenter
                    text: root.connectionTitle
                    font {
                        pixelSize: Theme.font.size.lg
                        family: Theme.font.family.inter_medium
                        weight: Font.Medium
                    }
                    color: Colors.on_surface
                }

                Text {
                    text: root.connectionSubtitle
                    font.pixelSize: Theme.font.size.sm
                    color: Colors.on_surface_variant
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MaterialSymbol {
                Layout.alignment: Qt.AlignVCenter
                icon: "check"
                iconSize: Theme.font.size.xl
                fontColor: Colors.primary
            }
        }
    }

    ColumnLayout {
        id: contentArea
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: children.length > 0
        spacing: 0
    }
}

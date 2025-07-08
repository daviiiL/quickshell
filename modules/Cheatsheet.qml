pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../utils/"
import "../components/"

Item {
    id: root
    required property var screen

    anchors {
        left: parent.right
    }

    function calculateWindowDimensions() {
        root.implicitWidth = screen.width * 0.45;
        root.implicitHeight = root.implicitWidth * 3 / 4;
    }

    function show() {
        modalLoader.item.visible = true;
    }

    function hide() {
        modalLoader.item.visible = false;
    }

    Component.onCompleted: {
        //initialize
        root.calculateWindowDimensions();
    }

    LazyLoader {
        id: modalLoader
        loading: true
        PanelWindow {
            id: modalWindow
            visible: false
            implicitHeight: root.implicitHeight
            implicitWidth: root.implicitWidth

            color: "transparent"

            Rectangle {
                id: modal
                anchors.fill: parent
                color: Colors.current.secondary_container
                radius: Theme.rounding.large

                readonly property int columnCnt: 2

                // function genRow(
                // // key: Text, icon: Text, val: Text
                // ) {
                //     var rowContainer = Qt.createComponent("Rectangle");
                //     if (rowContainer.status === Component.Ready) {
                //         var obj = rowContainer.createObject(parent, {
                //             [anchors.fill]: parent,
                //             color: "white"
                //         });
                //     }
                // }

                Text {
                    id: title
                    text: "Keybinds"
                    anchors.top: parent.top
                    anchors.topMargin: parent.width / 25
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Colors.current.on_secondary_container
                    font.family: Theme.font.style.inter
                    font.pointSize: Theme.font.size.large
                }

                RowLayout {

                    anchors {
                        top: title.bottom
                        left: parent.left
                        bottom: parent.bottom
                        right: parent.right
                    }

                    anchors.margins: modal.width / 20

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            Text {
                                id: firstText1
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: Math.max(firstText1.implicitWidth, firstText2.implicitWidth, firstText3.implicitWidth)
                                text: "Main Modifier"
                                font.pointSize: icon.font.pointSize
                                color: rect.color
                            }

                            Rectangle {
                                id: rect
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: icon.implicitWidth
                                implicitHeight: icon.implicitHeight
                                color: Colors.current.on_secondary_container
                                radius: Theme.rounding.small
                                MaterialSymbol {
                                    id: icon

                                    icon: "keyboard_command_key"
                                    fontColor: Colors.current.secondary_container
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: "Super"
                                font.pointSize: icon.font.pointSize
                                color: rect.color
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            Text {
                                id: firstText2
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: Math.max(firstText1.implicitWidth, firstText2.implicitWidth, firstText3.implicitWidth)
                                text: "Secondary Modifier"
                                font.pointSize: ctrlIcon.font.pointSize
                                color: ctrlRect.color
                            }

                            Rectangle {
                                id: ctrlRect
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: ctrlIcon.implicitWidth
                                implicitHeight: ctrlIcon.implicitHeight
                                color: Colors.current.on_secondary_container
                                radius: Theme.rounding.small
                                MaterialSymbol {
                                    id: ctrlIcon

                                    icon: "keyboard_control_key"
                                    fontColor: Colors.current.secondary_container
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: "Ctrl"
                                font.pointSize: ctrlIcon.font.pointSize
                                color: ctrlRect.color
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 20
                            Text {
                                id: firstText3
                                Layout.alignment: Qt.AlignVCenter
                                Layout.preferredWidth: Math.max(firstText1.implicitWidth, firstText2.implicitWidth, firstText3.implicitWidth)
                                text: "Third Modifier"
                                font.pointSize: altIcon.font.pointSize
                                color: altRect.color
                            }

                            Rectangle {
                                id: altRect
                                Layout.alignment: Qt.AlignVCenter
                                implicitWidth: altIcon.implicitWidth
                                implicitHeight: altIcon.implicitHeight
                                color: Colors.current.on_secondary_container
                                radius: Theme.rounding.small
                                MaterialSymbol {
                                    id: altIcon

                                    icon: "keyboard_alt"
                                    fontColor: Colors.current.secondary_container
                                }
                            }

                            Text {
                                Layout.alignment: Qt.AlignVCenter
                                text: "Alt"
                                font.pointSize: altIcon.font.pointSize
                                color: altRect.color
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Text {
                            text: "test"
                            font.pointSize: 20
                        }
                    }
                }
            }
        }
    }
}

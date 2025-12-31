pragma ComponentBehavior: Bound

import qs.services
import qs.common
import qs.widgets
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

MouseArea {
    id: root
    required property string matugenScheme
    required property var fileModelData
    required property int index
    required property var grid
    property bool isDirectory: fileModelData?.fileIsDir ?? false
    property bool useThumbnail: fileModelData ? Images.isValidImageByName(fileModelData.fileName) : false

    property color colBackground: Colors.primary_container
    property color colText: Colors.on_primary_container
    property real radius: Theme.ui.radius.md
    property real margins: 4
    property real padding: 8

    signal activated

    hoverEnabled: true
    onClicked: root.activated()

    Rectangle {
        id: background
        anchors {
            fill: parent
            margins: root.margins
        }
        radius: root.radius
        color: root.colBackground
        Behavior on color {
            ColorAnimation {
                duration: Theme.anim.durations.sm
                easing.type: Easing.InOutSine
            }
        }
        border {
            width: Theme.ui.borderWidth
            color: (root.index === root.grid.currentIndex) ? Colors.primary : "transparent"
        }
        Canvas {
            id: indicatorLine
            visible: root.index === root.grid.currentIndex
            anchors.fill: parent
            antialiasing: true

            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();

                ctx.strokeStyle = Colors.primary;
                ctx.lineWidth = 3;
                ctx.lineCap = "round";

                const lineY = 2;
                const lineWidth = root.width / 3;
                const startX = (width - lineWidth) / 2;
                const endX = startX + lineWidth;

                ctx.beginPath();
                ctx.moveTo(startX, lineY);
                ctx.lineTo(endX, lineY);
                ctx.stroke();
            }

            Component.onCompleted: {
                requestPaint();
            }

            Connections {
                target: Colors

                function onPrimaryChanged() {
                    indicatorLine.requestPaint();
                }
            }
        }
        ColumnLayout {
            id: wallpaperItemColumnLayout
            anchors {
                fill: parent
                margins: root.padding
            }
            spacing: 4

            Item {
                id: wallpaperItemImageContainer
                Layout.fillHeight: true
                Layout.fillWidth: true

                Loader {
                    id: thumbnailImageLoader
                    active: root.useThumbnail
                    anchors.fill: parent
                    sourceComponent: ThumbnailImage {
                        id: thumbnailImage
                        generateThumbnail: true
                        sourcePath: root.fileModelData?.filePath ?? ""

                        cache: false
                        fillMode: Image.PreserveAspectCrop
                        clip: true
                        sourceSize.width: wallpaperItemColumnLayout.width
                        sourceSize.height: wallpaperItemColumnLayout.height - wallpaperItemColumnLayout.spacing - wallpaperItemName.height

                        Connections {
                            target: Wallpapers
                            function onThumbnailGenerated(directory) {
                                if (FileUtils.parentDirectory(thumbnailImage.sourcePath) !== directory)
                                    return;
                                thumbnailImage.checkAndLoadThumbnail();
                            }
                            function onThumbnailGeneratedFile(filePath) {
                                if (Qt.resolvedUrl(thumbnailImage.sourcePath) !== Qt.resolvedUrl(filePath))
                                    return;
                                thumbnailImage.checkAndLoadThumbnail();
                            }
                        }

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle {
                                width: wallpaperItemImageContainer.width
                                height: wallpaperItemImageContainer.height
                                radius: Theme.ui.radius.sm
                            }
                        }
                    }
                }

                Loader {
                    id: iconLoader
                    active: !root.useThumbnail
                    anchors.fill: parent
                    sourceComponent: Item {
                        MaterialSymbol {
                            anchors.centerIn: parent
                            text: root.isDirectory ? "folder" : "image"
                            color: root.colText
                            fontColor: root.colText
                            iconSize: 64
                            icon: root.isDirectory ? "folder" : "image"
                        }
                    }
                }
            }

            StyledText {
                id: wallpaperItemName
                Layout.fillWidth: true
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                font.pixelSize: Theme.font.size.xs
                color: root.colText
                Behavior on color {
                    ColorAnimation {
                        duration: Theme.anim.durations.sm
                        easing.type: Easing.InOutSine
                    }
                }
                text: root.fileModelData?.fileName
            }
        }
    }
}

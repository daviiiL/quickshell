pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.common
import qs.widgets

Rectangle {
    id: root
    required property MprisPlayer player

    color: Colors.surface_container
    radius: Theme.ui.radius.lg

    Timer {
        running: root.player?.playbackState == MprisPlaybackState.Playing
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.md
        spacing: Theme.ui.padding.md

        Rectangle {
            Layout.fillHeight: true
            implicitWidth: height
            radius: Theme.ui.radius.sm
            color: Colors.surface_container_high

            StyledImage {
                id: albumArt
                anchors.fill: parent
                source: Qt.resolvedUrl(root.player?.trackArtUrl ?? "")
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        anchors.fill: parent
                        radius: Theme.ui.radius.sm
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            spacing: Theme.ui.padding.sm / 2

            StyledText {
                id: trackTitle
                Layout.fillWidth: true
                font.pixelSize: Theme.font.size.lg
                font.weight: Font.Medium
                color: Colors.on_surface
                elide: Text.ElideRight
                text: StringUtils.cleanMusicTitle(root.player?.trackTitle) || "Untitled"
            }

            StyledText {
                id: trackArtist
                Layout.fillWidth: true
                font.pixelSize: Theme.font.size.sm
                color: Colors.on_surface_variant
                elide: Text.ElideRight
                text: root.player?.trackArtist || "Unknown Artist"
            }

            Item {
                Layout.fillHeight: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.ui.padding.sm

                StyledText {
                    font.pixelSize: Theme.font.size.xs
                    color: Colors.on_surface_variant
                    text: StringUtils.friendlyTimeForSeconds(root.player?.position ?? 0)
                }

                Item {
                    Layout.fillWidth: true
                }

                StyledText {
                    font.pixelSize: Theme.font.size.xs
                    color: Colors.on_surface_variant
                    text: StringUtils.friendlyTimeForSeconds(root.player?.length ?? 0)
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: progressContainer.implicitHeight

                Loader {
                    id: progressContainer
                    anchors.fill: parent
                    active: root.player?.canSeek ?? false
                    sourceComponent: StyledSlider {
                        anchors.fill: parent
                        highlightColor: Colors.primary
                        trackColor: Colors.surface_container_highest
                        handleColor: Colors.primary
                        value: (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1)
                        onMoved: {
                            if (root.player && root.player.canSeek) {
                                root.player.position = value * root.player.length;
                            }
                        }
                    }
                }

                Loader {
                    anchors.fill: parent
                    active: !(root.player?.canSeek ?? false)
                    sourceComponent: StyledProgressBar {
                        anchors.fill: parent
                        highlightColor: Colors.primary
                        trackColor: Colors.surface_container_highest
                        value: (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1)
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.ui.padding.sm

                StyledButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    icon: "skip_previous"
                    clickable: root.player.canGoPrevious
                    onClicked: function () {
                        if (root.player)
                            root.player.previous();
                    }
                }

                StyledButton {
                    implicitWidth: 48
                    implicitHeight: 48
                    icon: root.player?.isPlaying ? "pause" : "play_arrow"
                    highlighted: true
                    iconSize: 25

                    onClicked: function () {
                        if (root.player)
                            root.player.togglePlaying();
                    }
                }

                StyledButton {
                    implicitWidth: 32
                    implicitHeight: 32
                    icon: "skip_next"
                    clickable: root.player.canGoNext
                    onClicked: function () {
                        if (root.player)
                            root.player.next();
                    }
                }
            }
        }
    }
}

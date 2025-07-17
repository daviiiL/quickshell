import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../utils/"
import "../components/"

Scope {
    id: root

    property real currentBrightness: 0
    property bool visible: false
    property int animationDuration: 100

    function getBrightnessIcon(val) {
        const numString = (val * 0.05 >= 1 ? val * 0.05 : 1).toFixed(0);
        return "brightness_" + numString;
    }

    Connections {
        target: Audio.defaultSinkAudio
        function onVolumeChanged() {
            root.visible = true;
            hideTimer.restart();
            fadeTimer.restart();
        }
        function onMutedChanged() {
            root.visible = true;
            hideTimer.restart();
            fadeTimer.restart();
        }
    }

    Connections {
        target: Brightness
        function onBrightnessChanged(val) {
            root.visible = true;
            root.currentBrightness = val;
            // console.log("brightness change signal received in osd", root.currentBrightness);
            hideTimer.restart();
            fadeTimer.restart();
        }
    }

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: {
            root.visible = false;
        }
    }

    Timer {
        id: fadeTimer
        interval: hideTimer.interval - root.animationDuration
        property bool shouldFade: false
        onTriggered: {
            shouldFade = true;
        }
    }

    LazyLoader {
        active: root.visible

        PanelWindow {
            id: osd
            anchors.right: true
            margins.right: 10

            implicitWidth: 140
            implicitHeight: 400
            color: "transparent"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.exclusiveZone: 0
            mask: Region {}

            Rectangle {
                id: rect
                anchors.fill: parent
                radius: Theme.rounding.large
                color: Colors.current.secondary_container

                opacity: 0.0

                Behavior on opacity {
                    NumberAnimation {
                        duration: root.animationDuration
                    }
                }

                Component.onCompleted: function () {
                    Qt.callLater(() => {
                        this.opacity = 1.0;
                    });
                }

                Connections {
                    target: root
                    function onVisibleChanged() {
                        if (root.visible) {
                            rect.opacity = 1.0;
                            fadeTimer.shouldFade = false;
                        }
                    }
                }

                Connections {
                    target: fadeTimer
                    function onShouldFadeChanged() {
                        if (fadeTimer.shouldFade) {
                            rect.opacity = 0;
                        }
                    }
                }

                RowLayout {
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: 10
                        rightMargin: 10
                    }
                    spacing: 10

                    Rectangle {
                        id: volume
                        implicitHeight: 380
                        implicitWidth: (osd.width - 30) / 2
                        radius: Theme.rounding.regular
                        color: Colors.current.primary_container

                        property real barHeight: volume.height * (Audio.volume > 1.0 ? 1.0 : Audio.volume) || 0.1

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            height: volume.barHeight
                            radius: parent.radius
                            color: Audio.muted ? Colors.current.primary_container : (Audio.isOverdrive ? Colors.current.on_error_container : Colors.current.on_primary_container)

                            Text {
                                visible: Audio.isOverdrive
                                text: {
                                    (Audio.volume * 100).toFixed(0) + "%";
                                }
                                anchors.centerIn: parent
                                color: Colors.current.error_container
                                font.family: Theme.font.style.inter
                                font.styleName: "Bold"
                                font.pointSize: 15
                            }

                            MaterialSymbol {
                                anchors {
                                    bottomMargin: 2
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }
                                colorAnimated: true
                                icon: Audio.volume == 0 || Audio.muted ? "volume_off" : (Audio.volume >= 0.5 ? "volume_up" : "volume_down")
                                fontColor: Audio.isOverdrive ? Colors.current.error_container : (Audio.volume <= 0.1 || Audio.muted ? Colors.current.on_primary_container : Colors.current.primary_container)
                            }

                            Behavior on height {
                                NumberAnimation {
                                    // target: brighnessBar
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
                                }
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.standard
                                }
                            }
                        }
                    }

                    Rectangle {
                        id: brightness
                        implicitWidth: (osd.width - 30) / 2
                        implicitHeight: 380
                        radius: Theme.rounding.regular
                        color: Colors.current.primary_container

                        property real barHeight: height * (root.currentBrightness / 100) || 0.1

                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                bottom: parent.bottom
                            }

                            height: brightness.barHeight
                            radius: parent.radius
                            color: Colors.current.on_primary_container

                            MaterialSymbol {
                                anchors {
                                    bottomMargin: 2
                                    bottom: parent.bottom
                                    horizontalCenter: parent.horizontalCenter
                                }
                                colorAnimated: true
                                icon: getBrightnessIcon(root.currentBrightness)
                                fontColor: root.currentBrightness <= 5 ? parent.color : Colors.current.primary_container
                            }

                            Behavior on height {

                                NumberAnimation {
                                    // target: brighnessBar
                                    duration: root.animationDuration
                                    easing.type: Easing.BezierSpline
                                    easing.bezierCurve: Theme.anim.curves.expressiveFastSpatial
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

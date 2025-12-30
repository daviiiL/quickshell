import QtQuick
import qs.common

Image {
    asynchronous: true
    retainWhileLoading: true
    visible: opacity > 0
    opacity: (status === Image.Ready) ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: Theme.anim.durations.sm
            easing.type: Easing.InOutSine
        }
    }
}

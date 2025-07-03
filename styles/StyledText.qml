import QtQuick
import "../utils"

Text {
    id: root

    property string fontSize
    property string fontStyle

    font.pointSize: Theme.font.size[fontSize]
    font.family: Theme.font.style[`inter_${fontStyle}`]
}

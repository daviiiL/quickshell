import QtQuick
import "../utils"

Text {
    id: root

    property string fontSize
    property string fontStyle

    font.pointSize: Config.font.size[fontSize]
    font.family: Config.font.style[`inter_${fontStyle}`]
}

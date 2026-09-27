import QtQuick
import qs.config

// Material Symbols Rounded icon via ligature, e.g. MaterialIcon { icon: "wifi" }
Text {
    property string icon: ""
    property real fill: 0
    property int size: 20

    text: icon
    color: Theme.fg
    font.family: Theme.fontIcon
    font.pixelSize: size
    font.variableAxes: ({ "FILL": fill, "opsz": Math.min(48, Math.max(20, size)), "wght": 450 })
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering

    Behavior on fill {
        NumberAnimation { duration: Theme.anim.fast }
    }
}

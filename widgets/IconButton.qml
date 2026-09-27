import QtQuick
import qs.config

Rectangle {
    id: root

    property string icon
    property int iconSize: 20
    property bool toggled: false
    property color iconColor: toggled ? Theme.fgPrimary : Theme.fg
    property color baseColor: "transparent"
    property string tooltip: ""
    readonly property alias hovered: layer.containsMouse

    signal clicked(var mouse)

    implicitWidth: iconSize + 16
    implicitHeight: iconSize + 16
    radius: Theme.radius.full
    color: toggled ? Theme.primary : baseColor

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }

    MaterialIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.iconSize
        color: root.iconColor
        fill: root.toggled ? 1 : 0
    }

    StateLayer {
        id: layer
        tint: root.iconColor
        onClicked: mouse => root.clicked(mouse)
    }
}

import QtQuick
import qs.config
import qs.widgets

// Rounded group used for bar modules.
Rectangle {
    id: root

    default property alias content: row.data
    property alias spacing: row.spacing
    property alias hovered: layer.containsMouse
    property bool active: false
    property int hPadding: 10

    signal clicked(var mouse)
    signal wheel(var wheel)

    implicitWidth: row.implicitWidth + hPadding * 2
    implicitHeight: 28
    radius: Theme.radius.full
    color: active ? Theme.primary : Theme.layer1

    Behavior on color {
        ColorAnimation { duration: Theme.anim.fast }
    }
    Behavior on implicitWidth {
        NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutCubic }
    }

    StateLayer {
        id: layer
        tint: root.active ? Theme.fgPrimary : Theme.fg
        onClicked: mouse => root.clicked(mouse)
        onWheel: wheel => root.wheel(wheel)
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }
}

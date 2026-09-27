import QtQuick
import qs.config

// Hover / press highlight + click handling for any rounded control.
MouseArea {
    id: root

    property color tint: Theme.fg
    property real radius: parent?.radius ?? 0
    property bool enabledHover: true

    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: root.tint
        opacity: !root.enabledHover ? 0 : root.pressed ? 0.16 : root.containsMouse ? 0.08 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }
}

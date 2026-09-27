import QtQuick
import qs.config

Rectangle {
    id: root

    property bool checked: false
    signal toggled

    implicitWidth: 52
    implicitHeight: 30
    radius: height / 2
    color: checked ? Theme.primary : Theme.surfaceContainerHighest
    border.width: checked ? 0 : 2
    border.color: Theme.outline

    Behavior on color {
        ColorAnimation { duration: Theme.anim.normal }
    }

    Rectangle {
        readonly property int size: root.checked ? 22 : 16
        width: size
        height: size
        radius: size / 2
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? root.width - width - 4 : 7
        color: root.checked ? Theme.fgPrimary : Theme.outline

        Behavior on x {
            NumberAnimation { duration: Theme.anim.normal; easing.type: Easing.OutBack }
        }
        Behavior on width {
            NumberAnimation { duration: Theme.anim.fast }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}

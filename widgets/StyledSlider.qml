import QtQuick
import QtQuick.Controls
import qs.config

// M3-style thick slider with an embedded icon.
Slider {
    id: root

    property string icon: ""
    property color accent: Theme.primary
    signal iconClicked

    from: 0
    to: 1
    implicitHeight: 40
    padding: 0
    wheelEnabled: true
    stepSize: 0.01

    background: Rectangle {
        x: root.leftPadding
        y: root.topPadding
        width: root.availableWidth
        height: root.availableHeight
        radius: Theme.radius.full
        color: Theme.layer2

        Rectangle {
            width: Math.max(height, root.visualPosition * parent.width)
            height: parent.height
            radius: Theme.radius.full
            color: root.accent

            Behavior on width {
                enabled: !root.pressed
                NumberAnimation { duration: Theme.anim.fast; easing.type: Easing.OutCubic }
            }
        }
    }

    handle: Item {
        x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
        y: root.topPadding
        width: root.availableHeight
        height: root.availableHeight
    }

    MaterialIcon {
        x: 10
        anchors.verticalCenter: parent.verticalCenter
        icon: root.icon
        size: 20
        fill: 1
        color: root.visualPosition * root.availableWidth > 36 ? Theme.fgPrimary : Theme.fg

        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    StyledText {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: Math.round(root.value * 100) + "%"
        font.pixelSize: Theme.fontSize.small
        font.weight: Font.Medium
        color: root.visualPosition > 0.88 ? Theme.fgPrimary : Theme.fgVariant
    }
}

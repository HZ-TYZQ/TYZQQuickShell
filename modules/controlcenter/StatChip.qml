import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

Rectangle {
    id: root

    property string icon
    property string label
    property string text
    property real value

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 48
    radius: Theme.radius.normal
    color: Theme.layer1
    clip: true

    // progress backdrop
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width * Math.max(0, Math.min(1, root.value))
        radius: parent.radius
        color: Qt.alpha(Theme.primary, 0.14)

        Behavior on width {
            NumberAnimation { duration: Theme.anim.slow; easing.type: Easing.OutCubic }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 8

        MaterialIcon {
            icon: root.icon
            size: 20
            color: Theme.primary
        }
        ColumnLayout {
            spacing: -2
            StyledText {
                text: root.label
                font.pixelSize: Theme.fontSize.small - 1
                color: Theme.fgVariant
            }
            StyledText {
                text: root.text
                font.weight: Font.Bold
                font.features: ({ "tnum": 1 })
            }
        }
    }
}

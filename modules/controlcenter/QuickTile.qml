import QtQuick
import QtQuick.Layouts
import qs.config
import qs.widgets

// M3-style quick settings tile: icon + title + subtitle, optional chevron.
Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active: false
    property bool hasMore: false

    signal clicked
    signal moreClicked

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 64
    radius: Theme.radius.large
    color: active ? Theme.primary : Theme.layer1

    Behavior on color {
        ColorAnimation { duration: Theme.anim.normal }
    }

    StateLayer {
        tint: root.active ? Theme.fgPrimary : Theme.fg
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 6
        spacing: 12

        MaterialIcon {
            icon: root.icon
            size: 22
            fill: root.active ? 1 : 0
            color: root.active ? Theme.fgPrimary : Theme.fg
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font.weight: Font.DemiBold
                color: root.active ? Theme.fgPrimary : Theme.fg
            }
            StyledText {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                font.pixelSize: Theme.fontSize.small
                color: root.active ? Qt.alpha(Theme.fgPrimary, 0.8) : Theme.fgVariant
            }
        }

        IconButton {
            visible: root.hasMore
            icon: "chevron_right"
            iconSize: 20
            iconColor: root.active ? Theme.fgPrimary : Theme.fg
            onClicked: root.moreClicked()
        }
    }
}

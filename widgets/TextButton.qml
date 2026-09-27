import QtQuick
import qs.config

Rectangle {
    id: root

    property string text
    property string icon: ""
    property bool primary: false

    signal clicked

    implicitWidth: row.implicitWidth + 28
    implicitHeight: 36
    radius: height / 2
    color: primary ? Theme.primary : Theme.secondaryContainer

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        MaterialIcon {
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
            icon: root.icon
            size: 18
            color: label.color
        }
        StyledText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: root.text
            font.weight: Font.DemiBold
            color: root.primary ? Theme.fgPrimary : Theme.fgSecondaryContainer
        }
    }

    StateLayer {
        tint: label.color
        onClicked: root.clicked()
    }
}

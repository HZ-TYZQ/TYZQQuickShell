import QtQuick
import QtQuick.Layouts
import qs.config
import qs.services
import qs.widgets

RowLayout {
    id: root

    property string title
    default property alias extra: slot.data

    Layout.fillWidth: true
    spacing: 8

    IconButton {
        icon: "arrow_back"
        onClicked: Ui.controlPage = "main"
    }

    StyledText {
        Layout.fillWidth: true
        text: root.title
        font.pixelSize: Theme.fontSize.title
        font.weight: Font.DemiBold
    }

    Row {
        id: slot
        spacing: 8
    }
}

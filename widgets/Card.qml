import QtQuick
import QtQuick.Effects
import qs.config

// Panel surface with shadow. Absorbs clicks so they don't reach the backdrop.
Item {
    id: root

    default property alias content: inner.data
    property alias color: bg.color
    property alias radius: bg.radius
    property alias border: bg.border
    property real padding: 16

    RectangularShadow {
        anchors.fill: bg
        radius: bg.radius
        blur: 24
        spread: 0
        offset.y: 6
        color: Qt.alpha(Theme.shadow, 0.45)
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Theme.radius.large
        color: Theme.panelBg
        border.width: 1
        border.color: Qt.alpha(Theme.outlineVariant, 0.6)
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        hoverEnabled: false
        onWheel: wheel => wheel.accepted = false
    }

    Item {
        id: inner
        anchors.fill: parent
        anchors.margins: root.padding
    }
}

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config
import qs.services

// Full-screen transparent layer that hosts a popup card.
// Clicking outside the card or pressing Escape closes it.
PanelWindow {
    id: root

    required property string name
    readonly property bool shown: Ui.panel === name
    property real progress: shown ? 1 : 0
    property bool dim: false
    property bool overlay: false
    property int focusMode: WlrKeyboardFocus.OnDemand
    property Item blurItem: null
    property real blurRadius: Theme.radius.large
    default property alias content: container.data

    screen: Ui.activeScreen
    visible: shown || progress > 0.001
    color: "transparent"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: overlay ? ExclusionMode.Ignore : ExclusionMode.Normal
    WlrLayershell.namespace: "quickshell-" + name
    WlrLayershell.layer: overlay ? WlrLayer.Overlay : WlrLayer.Top
    WlrLayershell.keyboardFocus: shown ? focusMode : WlrKeyboardFocus.None

    BackgroundEffect.blurRegion: Region {
        item: root.shown ? root.blurItem : null
        radius: root.blurRadius
    }

    Behavior on progress {
        NumberAnimation {
            duration: Theme.anim.normal
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Theme.anim.emphasized
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.dim ? 0.5 * root.progress : 0
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Ui.close()
    }

    Item {
        id: container
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Ui.close()
    }
}

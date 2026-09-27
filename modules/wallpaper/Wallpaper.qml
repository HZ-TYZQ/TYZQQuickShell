import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.config

PanelWindow {
    id: root

    required property ShellScreen modelData

    screen: modelData
    color: "black"
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-wallpaper"

    property string source: Config.options.wallpaper
    property bool flip: false

    onSourceChanged: {
        const next = flip ? a : b;
        next.source = "file://" + source;
    }

    Image {
        id: a
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize: Qt.size(root.width * (root.screen?.devicePixelRatio ?? 1), root.height * (root.screen?.devicePixelRatio ?? 1))
        opacity: root.flip ? 0 : 1
        onStatusChanged: if (status === Image.Ready && root.flip && source.toString().endsWith(root.source)) root.flip = false
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
        }
    }

    Image {
        id: b
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: false
        sourceSize: a.sourceSize
        opacity: root.flip ? 1 : 0
        onStatusChanged: if (status === Image.Ready && !root.flip && source.toString().endsWith(root.source)) root.flip = true
        Behavior on opacity {
            NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
        }
    }

    Component.onCompleted: a.source = "file://" + source
}

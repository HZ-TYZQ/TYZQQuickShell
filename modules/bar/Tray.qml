import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs.config
import qs.widgets

BarPill {
    id: root

    required property var window

    visible: SystemTray.items.values.length > 0
    hPadding: 8
    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Item {
            id: item

            required property SystemTrayItem modelData

            width: 24
            height: 24
            anchors.verticalCenter: parent?.verticalCenter

            IconImage {
                anchors.centerIn: parent
                implicitSize: 17
                source: item.modelData.icon
                asynchronous: true
            }

            StateLayer {
                radius: 12
                onClicked: mouse => {
                    const p = item.mapToItem(null, 0, item.height + 6);
                    if (mouse.button === Qt.RightButton || (item.modelData.onlyMenu && item.modelData.hasMenu))
                        item.modelData.display(root.window, p.x, p.y);
                    else if (mouse.button === Qt.MiddleButton)
                        item.modelData.secondaryActivate();
                    else
                        item.modelData.activate();
                }
                onWheel: wheel => item.modelData.scroll(wheel.angleDelta.y, false)
            }
        }
    }
}

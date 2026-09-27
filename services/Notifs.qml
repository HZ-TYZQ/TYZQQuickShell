pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import qs.config

Singleton {
    id: root

    // Wrapper objects, newest first.
    property var list: []
    readonly property var popups: list.filter(n => n.popup)
    readonly property int count: list.length
    readonly property bool dnd: Config.options.doNotDisturb

    function toggleDnd() {
        Config.options.doNotDisturb = !Config.options.doNotDisturb;
    }

    function clearAll() {
        for (const n of list.slice())
            n.notification.dismiss();
    }

    function _add(notification, popup) {
        const w = wrapper.createObject(root, {
            notification: notification,
            popup: popup
        });
        list = [w, ...list];
    }

    function _remove(w) {
        w.popup = false;
        list = list.filter(n => n !== w);
        // Keep the wrapper alive until list remove transitions have finished.
        w.destroy(1000);
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root._add(n, !root.dnd || n.urgency === NotificationUrgency.Critical);
        }

        Component.onCompleted: {
            for (const n of trackedNotifications.values)
                root._add(n, false);
        }
    }

    Component {
        id: wrapper

        QtObject {
            id: w

            required property Notification notification
            property bool popup: false
            property bool hovered: false
            readonly property date time: new Date()

            readonly property Timer timer: Timer {
                running: w.popup && !w.hovered && w.notification?.urgency !== NotificationUrgency.Critical
                interval: (w.notification?.expireTimeout ?? 0) > 0 ? w.notification.expireTimeout * 1000 : 6000
                onTriggered: w.popup = false
            }

            readonly property Connections conn: Connections {
                target: w.notification
                function onClosed() {
                    root._remove(w);
                }
            }
        }
    }
}

pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    property MprisPlayer manual: null
    readonly property MprisPlayer player: (manual && players.includes(manual)) ? manual : (players.find(p => p.isPlaying) ?? players[0] ?? null)

    readonly property bool active: player !== null
    readonly property bool playing: player?.isPlaying ?? false
    readonly property string title: player?.trackTitle || "未知曲目"
    readonly property string artist: player?.trackArtist || player?.identity || ""
    readonly property string artUrl: player?.trackArtUrl ?? ""

    function toggle() {
        if (player?.canTogglePlaying)
            player.togglePlaying();
    }
    function next() {
        if (player?.canGoNext)
            player.next();
    }
    function previous() {
        if (player?.canGoPrevious)
            player.previous();
    }
    function cycle() {
        if (players.length < 2)
            return;
        manual = players[(players.indexOf(player) + 1) % players.length];
    }

    function formatTime(sec) {
        sec = Math.max(0, Math.floor(sec));
        const m = Math.floor(sec / 60), s = sec % 60;
        return `${m}:${s < 10 ? "0" : ""}${s}`;
    }

    // Position is not change-notified by MPRIS; poll while playing.
    Timer {
        running: root.playing
        repeat: true
        interval: 1000
        onTriggered: root.player?.positionChanged()
    }
}

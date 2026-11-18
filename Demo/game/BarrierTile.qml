import QtQuick

Column {
    id: barrier
    objectName: "barrierStatus"
    required property int charges
    required property int capacity
    required property real timeLeft
    required property real cooldown
    required property bool refilling
    property int installed: 0
    spacing: 4

    Text {
        width: parent.width
        text: "BARRIER" + (barrier.charges ? "  " + barrier.charges + "/" + barrier.capacity : "")
        color: barrier.charges ? "#a4e0ff" : "#b7c1d8"
        font.family: "IBM Plex Mono"
        font.pixelSize: 10
    }
    Row {
        width: parent.width
        spacing: 3
        Repeater {
            model: Math.max(2, barrier.capacity)
            Rectangle {
                required property int index
                width: (barrier.width - (Math.max(2, barrier.capacity) - 1) * 3) / Math.max(2, barrier.capacity)
                height: 4
                radius: 2
                color: index < barrier.charges ? (barrier.refilling ? "#e2faff" : "#79ccf6") : "#394151"
            }
        }
    }
    Text {
        width: parent.width
        text: barrier.charges ? barrier.timeLeft > 0 ? barrier.timeLeft.toFixed(1) + "s"
            : "CORE · LV " + barrier.installed
            : barrier.installed || barrier.timeLeft > 0 ? "SHATTERED" : barrier.cooldown < 0 ? "OFFLINE"
                : barrier.cooldown > 0 ? "COOLDOWN  " + Math.ceil(barrier.cooldown) + "s" : "ABILITY READY"
        font.family: "IBM Plex Mono"
        font.pixelSize: 9
        color: barrier.charges ? "#b5e9ff" : "#bac0d3"
        elide: Text.ElideRight
    }
}

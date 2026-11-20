import QtQuick
import "../ui" as Ui

Column {
    id: barrier
    objectName: "barrierStatus"
    required property int charges
    required property int capacity
    required property real timeLeft
    required property real cooldown
    required property bool refilling
    property int installed: 0
    property bool persistent:false
    spacing: 4

    Text {
        width: parent.width
        text: "BARRIER" + (barrier.charges ? "  " + barrier.charges + "/" + barrier.capacity : "")
        color: barrier.charges ? "#91f4ff" : "#b7c1d8"
        font.family: "IBM Plex Mono"
        font.pixelSize: Ui.UiMetrics.text(12)
    }
    Row {
        width: parent.width
        spacing: 3
        Repeater {
            model: Math.max(2, barrier.capacity)
            Rectangle {
                required property int index
                width: (barrier.width - (Math.max(2, barrier.capacity) - 1) * 3) / Math.max(2, barrier.capacity)
                height: 7
                radius: 2
                color: index < barrier.charges ? (barrier.refilling ? "#e2faff" : "#38e7ef") : "#394151"
            }
        }
    }
    Text {
        width: parent.width
        text: barrier.charges ? barrier.timeLeft > 0 ? barrier.timeLeft.toFixed(1) + "s"
            : barrier.installed ? "CORE · LV " + barrier.installed : "EQUIPPED"
            : barrier.persistent || barrier.timeLeft > 0 ? "SHATTERED" : barrier.cooldown < 0 ? "OFFLINE"
                : barrier.cooldown > 0 ? "COOLDOWN  " + Math.ceil(barrier.cooldown) + "s" : "ABILITY READY"
        font.family: "IBM Plex Mono"
        font.pixelSize: Ui.UiMetrics.text(11)
        color: barrier.charges ? "#92f5ff" : "#bac0d3"
        elide: Text.ElideRight
    }
}

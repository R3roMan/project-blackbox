import QtQuick

Item {
    id: glow
    required property color tint
    property real corner: 6
    property bool motion: true
    property real pulse: .56
    visible: tint.a > 0

    NumberAnimation on pulse {
        from: .18
        to: .85
        duration: 1750
        loops: Animation.Infinite
        running: glow.visible && glow.motion
        easing.type: Easing.InOutSine
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: glow.corner + 2
        color: "transparent"
        border.color: Qt.rgba(glow.tint.r, glow.tint.g, glow.tint.b, .16 + glow.pulse * .21)
        border.width: 2
    }
    Rectangle {
        anchors.fill: parent
        radius: glow.corner
        color: "transparent"
        border.color: Qt.lighter(glow.tint, 1.13)
        border.width: 2
    }
    Rectangle {
        width: Math.min(24, parent.width * .34)
        height: 2
        x: 5 + (parent.width - width - 10) * glow.pulse
        y: 1
        radius: 1
        color: "#f5ffffff"
        opacity: .45 + glow.pulse * .45
    }
}

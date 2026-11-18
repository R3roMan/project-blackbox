import QtQuick
import QtQuick.Controls

Button {
    id: control

    property bool selected: false
    property color accent: "#f2c18a"
    property bool compact: false

    implicitHeight: compact ? 34 : 40
    leftPadding: compact ? 9 : 13
    rightPadding: leftPadding
    topPadding: 6
    bottomPadding: 6
    font.pixelSize: compact ? 12 : 13
    font.weight: selected ? Font.DemiBold : Font.Medium

    contentItem: Text {
        text: control.text
        font: control.font
        color: !control.enabled ? "#7a808e" : control.selected ? "#14151d" : "#eef0f5"
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: 7
        color: control.selected ? control.accent
            : control.down ? "#374153" : control.hovered ? "#283142" : "#1a2130"
        border.width: control.visualFocus ? 2 : 1
        border.color: control.visualFocus ? control.accent : control.selected ? control.accent : "#3c475a"
        opacity: control.enabled ? 1 : .7
    }
}

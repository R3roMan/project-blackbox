import QtQuick

Item {
    id: meter

    required property string label
    required property real value
    required property real maximum
    required property color tint
    property string suffix: ""

    implicitWidth: 144
    implicitHeight: 27

    Text {
        text: meter.label
        color: "#b9abb9"
        font.family: "Inter"
        font.pixelSize: 11
        font.weight: Font.DemiBold
    }
    Text {
        anchors.right: parent.right
        text: String(Math.ceil(meter.value)) + meter.suffix
        color: "#fff4ec"
        font.family: "IBM Plex Mono"
        font.pixelSize: 12
    }
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 4
        radius: 2
        color: "#55434f"

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, meter.value / meter.maximum))
            height: parent.height
            radius: 2
            color: meter.tint
        }
    }
}

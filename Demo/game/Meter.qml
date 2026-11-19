import QtQuick
import "../ui" as Ui

Item {
    id: meter
    required property string label
    required property real value
    required property real maximum
    required property color tint
    property string suffix:""
    property bool prominent:false
    property bool motion:true
    readonly property real fraction:Math.max(0,Math.min(1,value/Math.max(1,maximum)))
    implicitWidth:144
    implicitHeight:Math.max(caption.implicitHeight,reading.implicitHeight)+(prominent ? 17 : 7)

    Text {
        id:caption
        anchors.left:parent.left
        anchors.right:reading.left
        anchors.rightMargin:4
        anchors.verticalCenter:reading.verticalCenter
        text:meter.label
        color:meter.prominent ? "#f8dcda" : "#d1c2cf"
        font.family:"Inter"
        font.pixelSize:Ui.UiMetrics.text(meter.prominent ? 13 : 11)
        font.weight:Font.DemiBold
        elide:Text.ElideRight
    }
    Text {
        id:reading
        anchors.right:parent.right
        text:Math.ceil(meter.value)+meter.suffix
        color:"#fff4ec"
        font.family:"IBM Plex Mono"
        font.weight:meter.prominent ? Font.Bold : Font.Medium
        font.pixelSize:Ui.UiMetrics.text(meter.prominent ? 23 : 12)
    }
    Rectangle {
        id:track
        anchors.bottom:parent.bottom
        width:parent.width
        height:meter.prominent ? 12 : 5
        radius:2
        color:"#422c36"
        clip:true
        Rectangle {
            visible:meter.prominent
            width:track.width*meter.fraction
            height:track.height
            color:"#ffdfb0"
            Behavior on width { enabled:meter.motion && meter.prominent; NumberAnimation {duration:380;easing.type:Easing.OutQuad} }
        }
        Rectangle {
            width:track.width*meter.fraction
            height:track.height
            radius:track.radius
            color:meter.tint
            Rectangle {visible:meter.prominent; width:parent.width;height:2;color:"#ffd7c8"}
        }
        Repeater {
            model:meter.prominent ? 3 : 0
            Rectangle {
                required property int index
                x:Math.round(track.width*(index+1)/4)
                width:2; height:track.height
                color:"#92573444"
            }
        }
    }
}

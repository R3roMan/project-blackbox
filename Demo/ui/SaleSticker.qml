pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: sticker
    required property int sale
    implicitWidth:mark.implicitWidth+12
    implicitHeight:mark.implicitHeight+6
    color:sale>=50 ? "#9d1d3e" : "#76213b"
    border.color:sale>=50 ? "#ffc87f" : "#ed7879"
    radius:3

    Text {
        id: mark
        anchors.centerIn:parent
        text:sticker.sale===100 ? "FREE" : sticker.sale===50 ? "SUPER DEAL  −50%" : "−"+sticker.sale+"%"
        color:"#fff0d6"
        font.family:"Inter"
        font.bold:true
        font.pixelSize:UiMetrics.text(10)
    }
}

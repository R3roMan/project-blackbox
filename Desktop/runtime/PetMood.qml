import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:meter
    required property real mood
    property string name:"Pet"
    spacing:3
    readonly property string feeling:mood<.14 ? "Upset" : mood<.39 ? "Annoyed" : mood>.72 ? "Happy" : "Neutral"
    readonly property color tint:mood<.39 ? "#f18e83" : mood>.72 ? "#92e3af" : "#e8c785"
    Label {
        Layout.fillWidth:true;text:meter.name+" · "+meter.feeling
        color:meter.tint;font.pixelSize:13;elide:Text.ElideRight
    }
    Rectangle {
        Layout.fillWidth:true;Layout.preferredHeight:7
        radius:3;color:"#34303c"
        Rectangle {width:parent.width*Math.max(0,Math.min(1,meter.mood));height:parent.height;radius:3;color:meter.tint}
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: comparison
    required property var rows
    visible:rows.length>0
    spacing:3

    Text {
        text:"Equipped → Offered"
        font.family:"Inter"
        font.bold:true
        font.pixelSize:UiMetrics.text(12)
        color:"#dfc4d4"
    }
    Repeater {
        model:comparison.rows
        RowLayout {
            required property var modelData
            Layout.fillWidth:true
            spacing:5

            Text {
                Layout.fillWidth:true
                text:parent.modelData.label
                font.family:"Inter"
                font.pixelSize:UiMetrics.text(12)
                color:"#e3d6e3"
            }
            Text {
                text:parent.modelData.original+"  →"
                font.family:"IBM Plex Mono"
                font.pixelSize:UiMetrics.text(11)
                color:"#b5afc1"
            }
            Text {
                text:parent.modelData.offered+(parent.modelData.delta>0 ? " ↑" : parent.modelData.delta<0 ? " ↓" : "")
                font.family:"IBM Plex Mono"
                font.pixelSize:UiMetrics.text(12)
                color:parent.modelData.delta>0 ? "#93efad" : parent.modelData.delta<0 ? "#ff969c" : "#efe3e9"
            }
        }
    }
}

import QtQuick
import "../ui" as Ui
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:preparation
    objectName:"stagePreparation"
    required property var run
    required property int revision
    property bool compact:false
    property bool motion:true
    signal entryRequested(string chapter, string id)
    signal swapRequested(string group,int from,int to)
    signal inventoryRequested(int cell,string group,int slot)
    spacing:6
    Text {
        text:"LOADOUT"
        color:Ui.InterfaceTheme.text
        font.family:Ui.InterfaceTheme.heading
        font.pixelSize:Ui.UiMetrics.text(17)
    }
    InventoryPanel {
        id:gear
        Layout.fillWidth:true
        run:preparation.run
        revision:preparation.revision
        dense:preparation.compact
        animate:preparation.motion
        onEntryRequested:function(chapter,id) { preparation.entryRequested(chapter,id) }
        onMoved:function(cell,group,slot) { preparation.inventoryRequested(cell,group,slot) }
        onSwapped:function(group,from,to) { preparation.swapRequested(group,from,to) }
    }
}

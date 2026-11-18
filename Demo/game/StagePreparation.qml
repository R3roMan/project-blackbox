import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id:preparation
    objectName:"stagePreparation"
    required property var run
    required property int revision
    property bool compact:false
    property bool motion:true
    signal swapRequested(string group,int from,int to)
    signal inventoryRequested(int cell,string group,int slot)
    spacing:6
    Text {
        text:"LOADOUT"
        color:"#eac2aa"
        font.family:"IBM Plex Mono"
        font.pixelSize:12
    }
    ScrollView {
        id:loadout
        Layout.fillWidth:true
        Layout.preferredHeight:Math.min(preparation.compact ? 220 : 320,gear.implicitHeight)
        contentWidth:availableWidth
        clip:true
        ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
        InventoryPanel {
            id:gear
            width:loadout.availableWidth-10
            run:preparation.run
            revision:preparation.revision
            dense:preparation.compact
            animate:preparation.motion
            onMoved:function(cell,group,slot) {preparation.inventoryRequested(cell,group,slot)}
            onSwapped:function(group,from,to) {preparation.swapRequested(group,from,to)}
        }
    }
}

import QtQuick
import "../game/Loadout.js" as Gear

Text {
    id: badge
    property var run:null
    property var kit:null
    property int revision:0
    readonly property string status:{revision;return run && kit ? Gear.kitStatus(run,kit) : ""}
    objectName:"kitStatus-"+(kit ? kit.key || kit.weapon : "")
    visible:status.length>0
    text:status
    color:status==="Active" ? InterfaceTheme.equipped : InterfaceTheme.inactive
    font.family:"IBM Plex Mono"
    font.bold:true
    font.pixelSize:UiMetrics.text(12)
}

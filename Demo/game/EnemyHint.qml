import QtQuick
import QtQuick.Controls
import "Encounters.js" as Mission
import "EnemyLore.js" as Lore

ToolTip {
    id:tip
    required property string enemyType
    required property var discoveries
    readonly property var spec:Mission.enemyTypes[enemyType] || Mission.enemyTypes.silophosus
    readonly property bool encountered:discoveries.includes(enemyType)
    width:Math.min(450,ApplicationWindow.window ? ApplicationWindow.window.width-36 : 450)
    readonly property point sceneOrigin:parent ? parent.mapToItem(null,0,0) : Qt.point(0,0)
    x:Math.max(12-sceneOrigin.x,Math.min((parent.width-width)/2,
        (ApplicationWindow.window ? ApplicationWindow.window.width : 760)-sceneOrigin.x-width-12))
    y:Math.max(12-sceneOrigin.y,Math.min(parent.height+8,
        (ApplicationWindow.window ? ApplicationWindow.window.height : 530)-sceneOrigin.y-height-12))
    padding:14
    delay:180
    contentItem:Column {
        spacing:7
        Text {
            width:parent.width
            text:tip.encountered ? tip.spec.title : "Unknown"
            font.family:"Inter"; font.pixelSize:16; font.bold:true
            color:"#fff1e4"; wrapMode:Text.WordWrap
        }
        Text {
            width:parent.width
            textFormat:Text.RichText
            text:"<font color='"+Lore.origins[tip.spec.origin].color+"'>"+tip.spec.origin+"</font>"
                +"  ·  <font color='"+Mission.tierColors[Mission.tier(tip.spec.id)]+"'>"+Mission.tier(tip.spec.id)+"</font>"
            font.family:"IBM Plex Mono"; font.pixelSize:13
            color:"#c5bdce"
        }
        Text {
            width:parent.width
            visible:tip.encountered
            text:tip.spec.description
            font.family:"Inter"; font.pixelSize:14
            color:"#e6d5df"; wrapMode:Text.WordWrap
        }
    }
    background:Rectangle {color:"#241b2b"; radius:5; border.color:"#a27f96"; border.width:2}
}

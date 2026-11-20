import QtQuick
import "../ui" as Ui
import "Loadout.js" as Gear

Rectangle {
    id: tile
    required property string shortcut
    required property var abilityState
    property bool motion: true
    property string details: ""
    signal castRequested()
    signal entryRequested(string chapter, string id)
    readonly property var ability: abilityState.ability
    readonly property string label:ability ? ability.title : abilityState.available ? "empty" : "locked"

    implicitWidth: 56
    implicitHeight: 56
    radius: 7
    color: "#e3151b2a"
    border.color: ability ? Gear.rarities[ability.rarity].color : "#61637a"
    Accessible.name: shortcut + " " + label
    Accessible.role:Accessible.Button
    Accessible.onPressAction:if (ability) tile.castRequested()
    MouseArea {
        anchors.fill:parent
        enabled:!!tile.ability
        cursorShape:enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked:tile.castRequested()
    }

    HoverHandler {id:inspect; enabled:!!tile.ability}
    Ui.FieldHint {
        anchorItem:tile
        hovered:inspect.hovered
        details:tile.details
        chapter:"abilities"
        entryId:tile.ability?.id || ""
        onEntryRequested:function(chapter,id) {tile.entryRequested(chapter,id)}
    }
    Ui.AbilityGlyph {
        visible:!!tile.ability
        anchors.centerIn:parent
        width:34; height:34
        entry:tile.ability
        tint:tile.border.color
    }
    UpgradeRim {
        anchors.fill: parent
        tint: tile.abilityState.upgradeColor
        corner: tile.radius
        motion: tile.motion
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height:tile.ability ? parent.height*Math.min(1,tile.abilityState.cooldown/tile.abilityState.duration) : 0
        color:"#66ffffff";radius:5
    }
    Ui.ChainedLock {visible:!tile.abilityState.available}
    Text {
        anchors.right:parent.right;anchors.bottom:parent.bottom;anchors.margins:5
        text:tile.abilityState.cooldown>0 ? Math.ceil(tile.abilityState.cooldown)+"s" : ""
        font.family:"IBM Plex Mono";font.bold:true;font.pixelSize:Ui.UiMetrics.text(12)
        color:"white";style:Text.Outline;styleColor:"#191723"
    }
}

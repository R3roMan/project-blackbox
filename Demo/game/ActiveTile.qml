import QtQuick
import "../ui" as Ui
import "Loadout.js" as Gear

Rectangle {
    id: tile
    required property string shortcut
    required property var abilityState
    property bool motion: true
    readonly property var ability: abilityState.ability
    readonly property string label: ability ? ability.title : abilityState.available ? "Empty" : "Locked"

    implicitWidth: 108
    implicitHeight: 96
    radius: 7
    color: "#e3151b2a"
    border.color: ability ? Gear.rarities[ability.rarity].color : "#61637a"
    Accessible.name: shortcut + " " + label

    UpgradeRim {
        anchors.fill: parent
        tint: tile.abilityState.upgradeColor
        corner: tile.radius
        motion: tile.motion
    }
    Text {
        x: 9
        y: 8
        text: tile.shortcut
        font.family: "IBM Plex Mono"
        font.weight: Font.Bold
        font.pixelSize: Ui.UiMetrics.text(20)
        color: "#f1eff9"
    }
    Text {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 9
        text: tile.abilityState.cooldown > 0 ? Math.ceil(tile.abilityState.cooldown) + "s"
            : tile.ability ? "Lv " + tile.abilityState.level : ""
        font.pixelSize: Ui.UiMetrics.text(13)
        font.family: "IBM Plex Mono"
        color: "#ffffff"
    }
    Text {
        anchors.fill: parent
        anchors.margins: 9
        anchors.topMargin: 34
        anchors.bottomMargin: 18
        text: tile.label
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        color: tile.ability ? "#f5eaf9" : "#b7b2c4"
        font.family: "Inter"
        font.pixelSize: Ui.UiMetrics.text(14)
    }
    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 9
        height: 4
        radius: 2
        color: "#53586b"
        Rectangle {
            width: tile.ability ? parent.width * (1 - Math.min(1, tile.abilityState.cooldown / tile.abilityState.duration)) : 0
            height: parent.height
            color: "#ffffff"
            radius: 2
        }
    }
}

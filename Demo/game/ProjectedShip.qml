import QtQuick
import "Rules.js" as Rules

Item {
    id: ship
    required property var enemy
    required property int revision
    required property real time
    property bool silhouette:false
    property bool frozen:false
    readonly property bool live: { revision; return enemy.hp > 0 && enemy.warp <= 0 }
    readonly property bool coreOpen: { revision; return enemy.turrets.every(function(part) { return part.hp <= 0 }) }
    readonly property real wreck: { revision; return enemy.wreck || 0 }
    readonly property real barrier: { revision; return enemy.barrier }
    readonly property real shatter: { revision; return enemy.shatter || 0 }
    readonly property real centerLine: .34

    function pick(x, y) {
        if (!live)
            return 0
        for (let i = 0; i < turrets.count; i += 1) {
            const gun = turrets.itemAt(i)
            if (gun.visible && Math.hypot((x - gun.x - gun.width / 2) / gun.width, (y - gun.y - gun.height / 2) / gun.height) < .60)
                return enemy.turrets[i].targetId
        }
        if (coreOpen && Math.hypot((x - width / 2) / core.width, (y - core.y - core.height / 2) / core.height) < .60)
            return enemy.id
        return 0
    }

    Rectangle {
        y: parent.height * .04
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * .95
        height: parent.height * .50
        radius: height * .47
        color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#383e5c"
        border.color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#8a9abb"
        border.width: 2
    }
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * .06
        width: parent.width * .81
        height: parent.height * .33
        radius: height * .49
        color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#5e6789"
        border.color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#b0bfdc"
        border.width: 2
    }
    Rectangle {
        y: parent.height * .48
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width * .75
        height: parent.height * .055
        radius: height * .44
        color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#ffac60"
        opacity: ship.wreck ? .2 + .75 * Math.abs(Math.sin(ship.time * 17)) : .87
    }
    Repeater {
        id: turrets
        model: ship.enemy.turrets
        Rectangle {
            id: tube
            required property var modelData
            required property int index
            readonly property var part: ship.enemy.turrets[index]
            visible: { ship.revision; return part.hp > 0 }
            readonly property real recoil: { ship.revision; return part.flash }
            x: { ship.revision; return parent.width * (.50 + (part.lane ?? (index-1)*238)/870) - width/2 }
            y: { ship.revision; return parent.height * (ship.centerLine - (part.height ?? -145)/430) - height/2 }
            width: parent.width * .105
            height: parent.height * .145
            radius: height * .38
            color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#252a40"
            border.color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : part.tint
            border.width: 2
            Rectangle {
                readonly property real dx: ship.width*(.50+(tube.part.baseLane ?? (tube.index-1)*238)/870)-tube.x-tube.width*.5
                readonly property real dy: ship.height*.38-tube.y-tube.height*.50
                x: tube.width*.35
                y: tube.height*.50
                z: -1
                transformOrigin: Item.Top
                rotation: -Math.atan2(dx,dy)*180/Math.PI
                width: tube.width*.30
                height: Math.hypot(dx,dy)
                color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#303143"
                border.color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#8c8693"
                border.width: 1
                radius: width*.37
            }
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * (.65 + tube.recoil * .55)
                height: parent.height * (.64 + tube.recoil * .5)
                radius: height * .45
                color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : tube.part.tint
                opacity: .53 + tube.recoil
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: parent.height + 3
                width: { ship.revision; return parent.width * tube.part.hp / tube.part.maximum }
                height: 2
                color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : tube.part.tint
            }
        }
    }
    Rectangle {
        id: core
        visible: ship.coreOpen
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * ship.centerLine - height / 2
        width: parent.width * .19
        height: parent.height * .49
        radius: height / 2
        color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#fff2aa"
        border.color: ship.silhouette ? "#050407" : ship.frozen ? "#aacfee" : "#eb844d"
        border.width: 4
    }
    Rectangle {
        visible: ship.barrier > 0
        anchors.fill: parent
        radius: height * .48
        border.color: "#aeddff"
        border.width: 2
        color: "#394eafff"
    }
    Repeater {
        model: 9
        Rectangle {
            required property int index
            readonly property real shift: (ship.time * (2.5 + index * .07) + index * 2.49) % 1
            visible: ship.wreck > 0 || ship.shatter > 0
            x: parent.width * (.5 + Math.cos(index * 2.4) * (.39 + shift * .1)) - width / 2
            y: parent.height * (.5 + Math.sin(index * 2.4) * (.31 + shift * .22)) - height / 2
            width: parent.height * (.09 + shift * .67)
            height: width
            radius: width / 2
            opacity: (1 - shift) * (ship.wreck ? .86 : ship.shatter / .48)
            color: ship.wreck ? (index % 3 ? "#ff814b" : "#ffe6b1") : "#aeddff"
        }
    }
}

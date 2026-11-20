import QtQuick
import "Pets.js" as Pets
import "../ui" as Ui

Item {
    id:idle
    required property string front
    property bool software:false
    property bool roaming:true
    property int floorInset:0
    property var helper:Pets.spec("crow")
    property string pose:"flight"
    property real clock:0
    property bool affectionate:false
    ListModel {id:marks}
    readonly property real floorY:Math.max(0,height-floorInset-creature.height-6)
    readonly property real petWidth:Math.min(width*.36,Math.max(190,(height-floorInset)*.31))

    function reload() {
        const available=Pets.pets.filter(pet=>pet.id!==helper.id && !pet.tarot)
        helper=available[Math.floor(Math.random()*available.length)]
        pose="flight"
        wander.restart()
    }
    function choosePose() {
        if (pointer.drag.active) return
        const roll=Math.random()
        pose=roll<.48 ? "flight" : roll<.66 ? "feed" : roll<.78 ? "scratch" : roll<.91 ? "spin" : "sleep"
        creature.x=16+Math.random()*Math.max(0,width-creature.width-32)
        creature.y=pose==="flight" || pose==="spin" ? height*(.15+Math.random()*.48) : floorY
        if (pose==="flight" && Math.random()<.35) {
            let count=0
            for (let i=0;i<marks.count;++i) count+=Number(marks.get(i).spotFront===front)
            if (count<4) marks.append({spotFront:front,horizontal:(creature.x+creature.width*.53)/Math.max(1,width),dropY:creature.y+creature.height*.65})
        }
        wander.interval=pose==="sleep" ? 6800 : (pose==="flight" ? 3600 : 4500)
    }
    onFrontChanged:if (roaming && !pointer.drag.active) {pose="flight";choosePose()}
    Component.onCompleted:{reload();creature.x=Math.max(0,width*.74-creature.width/2);creature.y=Math.min(floorY,height*.29)}
    Timer {id:wander;interval:3300;repeat:true;running:idle.roaming;onTriggered:idle.choosePose()}
    Timer {interval:83;repeat:true;running:idle.roaming;onTriggered:idle.clock=(idle.clock+.083)%120}
    Timer {id:hearts;interval:1250;onTriggered:idle.affectionate=false}
    Item {
        id:creature
        objectName:"idlePetBody"
        width:idle.petWidth;height:width*99/134
        onWidthChanged:if (x+width>idle.width) x=Math.max(0,idle.width-width)
        onHeightChanged:if (y>idle.floorY) y=idle.floorY
        Behavior on x {enabled:!pointer.pressed;NumberAnimation {duration:1850;easing.type:Easing.InOutSine}}
        Behavior on y {enabled:!pointer.pressed;NumberAnimation {duration:1850;easing.type:Easing.InOutSine}}
        Rectangle {
            anchors.horizontalCenter:parent.horizontalCenter;anchors.bottom:parent.bottom
            width:parent.width*.48;height:width*.16;radius:height/2
            color:Qt.rgba(Ui.FieldStyle.petGlow.r,Ui.FieldStyle.petGlow.g,Ui.FieldStyle.petGlow.b,.23)
        }
        Loader {
            anchors.fill:parent
            rotation:pointer.drag.active ? -17 : idle.pose==="spin" ? (idle.clock*210)%360
                : idle.pose==="feed" ? 15+Math.sin(idle.clock*13)*12 : idle.pose==="scratch" ? Math.sin(idle.clock*17)*18 : 0
            sourceComponent:idle.software ? flat : solid
        }
        Component {
            id:solid
            PetPortrait3D {
                helper:idle.helper;clock:idle.clock;animate:true
                textureWidthLimit:900
                resting:!pointer.drag.active && ["feed","sleep","scratch"].includes(idle.pose)
            }
        }
        Component {
            id:flat
            ProjectedPet {
                helper:idle.helper;flap:Math.sin(idle.clock*(pointer.drag.active ? 21 : 9))
                resting:!pointer.drag.active && ["feed","sleep","scratch"].includes(idle.pose)
                glowTint:Ui.FieldStyle.petGlow
            }
        }
        Text {
            anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top
            text:idle.affectionate ? "♥  ♥" : idle.pose==="sleep" && !pointer.pressed ? "z z z" : ""
            color:idle.affectionate ? "#ffa5bf" : "#d3eff7";style:Text.Outline;styleColor:"#30243a"
            font.pixelSize:Math.max(1,Math.round(parent.width*.12));font.bold:true
            anchors.topMargin:Math.sin(idle.clock*3)*parent.height*.05
        }
        MouseArea {
            id:pointer
            anchors.fill:parent;anchors.margins:parent.width*.11
            drag.target:creature
            drag.minimumX:0;drag.maximumX:Math.max(0,idle.width-creature.width)
            drag.minimumY:0;drag.maximumY:idle.floorY
            cursorShape:pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onClicked:{idle.affectionate=true;hearts.restart()}
        }
    }
    Repeater {
        model:marks
        Item {
            id:mark
            required property int index
            required property string spotFront
            required property real horizontal
            required property real dropY
            visible:spotFront===idle.front
            width:47;height:26;x:Math.min(idle.width-width,Math.max(0,horizontal*idle.width-width/2))
            y:Math.max(0,idle.height-idle.floorInset-24)
            property bool landed:false
            SequentialAnimation {
                running:mark.visible && idle.roaming && !mark.landed
                ScriptAction {script:mark.y=mark.dropY}
                NumberAnimation {target:mark;property:"y";to:Math.max(0,idle.height-idle.floorInset-24);duration:620;easing.type:Easing.InQuad}
                ScriptAction {script:mark.landed=true}
            }
            Repeater {
                model:mark.landed ? 6 : 1
                Rectangle {
                    required property int index
                    x:mark.landed ? 8+(index*13)%29 : 19
                    y:mark.landed ? 10+(index*5)%11 : 0
                    width:mark.landed ? 9+index%3*6 : 7;height:mark.landed ? 4+index%3*3 : 12
                    rotation:index*31;radius:height*.5;color:index%2 ? "#ebe9de" : "#fffef5"
                    border.color:"#70c4bbc1"
                }
            }
            MouseArea {
                anchors.fill:parent;enabled:mark.landed;cursorShape:Qt.PointingHandCursor
                onClicked:marks.remove(mark.index)
            }
        }
    }
}

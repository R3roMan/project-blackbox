import QtQuick
import "Pets.js" as Pets
import "../ui" as Ui

Item {
    id:idle
    required property string front
    property bool software:false
    property bool roaming:true
    property bool motion:true
    property bool audioEnabled:true
    property int floorInset:0
    property var perchLookup:null
    property var helper:Pets.spec("crow")
    property string pose:"flight"
    property real clock:0
    property real poseEnd:0
    property real flightStart:0
    property real flightDuration:1
    property point origin:Qt.point(0,0)
    property point destination:origin
    property string arrival:"flight"
    property real heading:1
    property point cursor:Qt.point(-1,-1)
    property real cursorSeen:-100
    property real curiosityReady:12
    property real alertedUntil:0
    property bool affectionate:false
    property bool dragging:pointer.drag.active
    property double lastTick:0
    ListModel {id:marks}
    readonly property real floorY:Math.max(0,height-floorInset-creature.height-6)
    readonly property real petWidth:Math.min(width*.36,Math.max(190,(height-floorInset)*.31))
    readonly property real maxX:Math.max(0,width-creature.width)
    readonly property bool airborne:["flight","landing","curious","spin"].includes(pose)
    readonly property real bob:!motion || !airborne || dragging ? 0
        : creature.height*.056*(Math.sin(clock*8)+.38*Math.sin(clock*16-1))

    function observePointer(x,y) {
        if (x<0 || y<0 || x>width || y>height) return
        cursor=Qt.point(x,y)
        cursorSeen=clock
    }
    function chirp() {audio.item?.play("idle-chirp",.58)}
    function breathe() {audio.item?.play("idle-breath",.46)}
    function reload() {
        const available=Pets.pets.filter(pet=>pet.id!==helper.id && !pet.tarot)
        helper=available[Math.floor(Math.random()*available.length)]
        wander()
    }
    function beginFlight(x,y,next,seconds) {
        origin=Qt.point(creature.x,creature.y)
        destination=Qt.point(Math.max(0,Math.min(maxX,x)),Math.max(0,Math.min(floorY,y)))
        if (Math.abs(destination.x-origin.x)>8) heading=destination.x>origin.x ? 1 : -1
        arrival=next
        pose=next==="flight" ? "flight" : "landing"
        flightStart=clock
        flightDuration=seconds
        poseEnd=clock+seconds
    }
    function wander() {
        if (dragging) return
        beginFlight(maxX*(.08+Math.random()*.84),floorY*(.13+Math.random()*.67),"flight",3.2+Math.random()*2.4)
    }
    function chooseLanding(next) {
        const candidates=typeof perchLookup==="function" ? perchLookup() : []
        const perch=candidates.length && Math.random()<.86 ? candidates[Math.floor(Math.random()*candidates.length)] : null
        // Feet reach the top edge. Keep the mouse target centred over the body.
        const x=perch ? perch.x+perch.width/2-creature.width/2 : maxX*(.08+Math.random()*.84)
        const y=perch ? perch.y-creature.height*.79 : floorY
        beginFlight(x,y,next,2.5+Math.random()*1.4)
    }
    function leaveDropping() {
        let count=0
        for (let i=0;i<marks.count;++i) count+=Number(marks.get(i).spotFront===front)
        if (count<4) marks.append({spotFront:front,
            horizontal:(creature.x+creature.width*(heading>0 ? .34 : .66))/Math.max(1,width),
            dropY:creature.y+creature.height*.69})
    }
    function startCuriosity() {
        pose="curious"
        poseEnd=clock+5.5
        curiosityReady=clock+24
    }
    function chase(dt) {
        const offsetX=cursor.x-(creature.x+creature.width*.5)
        const offsetY=cursor.y-(creature.y+creature.height*.48)
        const distance=Math.hypot(offsetX,offsetY)
        if (distance<Math.max(24,creature.width*.22)) {
            alertedUntil=clock+1.45
            chirp()
            wander()
        } else if (clock>=poseEnd) {
            wander()
        } else {
            const fraction=Math.min(1,dt*Math.max(105,width*.17)/distance)
            if (Math.abs(offsetX)>14) heading=offsetX>0 ? 1 : -1
            creature.x=Math.max(0,Math.min(maxX,creature.x+offsetX*fraction))
            creature.y=Math.max(0,Math.min(floorY,creature.y+offsetY*fraction))
        }
    }
    function tick(dt) {
        clock+=dt
        if (dragging) return
        if (pose==="curious") {chase(dt);return}
        if (pose==="flight" || pose==="landing") {
            const progress=Math.min(1,(clock-flightStart)/flightDuration)
            const eased=progress*progress*(3-2*progress)
            creature.x=Math.min(maxX,origin.x+(destination.x-origin.x)*eased)
            creature.y=Math.max(0,Math.min(floorY,origin.y+(destination.y-origin.y)*eased
                -(motion ? Math.sin(progress*Math.PI)*creature.height*(pose==="landing" ? .23 : .47) : 0)))
            if (progress<1) return
            if (pose==="landing") {
                pose=arrival
                poseEnd=clock+(pose==="sleep" ? 23+Math.random()*15 : 3.4+Math.random()*2)
                if (pose==="sleep") breathe()
                return
            }
        } else if (clock<poseEnd) return
        const roll=Math.random()
        if (clock>curiosityReady && clock-cursorSeen<8 && roll<.25) startCuriosity()
        else if (roll<.18) chooseLanding("sleep")
        else if (roll<.31) chooseLanding("feed")
        else if (roll<.43) chooseLanding("scratch")
        else if (roll<.51 && motion && pose==="flight") {pose="spin";poseEnd=clock+1.6}
        else {
            if (pose==="flight" && roll>.86) leaveDropping()
            wander()
        }
    }
    onFrontChanged:if (roaming && !dragging) wander()
    onDraggingChanged:if (dragging) chirp(); else wander()
    onRoamingChanged:lastTick=0
    Component.onCompleted:{
        creature.x=maxX*.75
        creature.y=floorY*.38
        reload()
    }
    Loader {
        id:audio
        active:idle.roaming && idle.audioEnabled
        sourceComponent:CuePlayer {defaultBus:"ambience"}
    }
    Timer {
        interval:idle.motion ? 33 : 83;repeat:true;running:idle.roaming
        onTriggered:{
            const now=Date.now()
            idle.tick(idle.lastTick ? Math.max(0,Math.min(.09,(now-idle.lastTick)*.001)) : interval*.001)
            idle.lastTick=now
        }
    }
    Timer {id:respiration;interval:4900;repeat:true;running:idle.roaming && idle.pose==="sleep" && !idle.dragging;onTriggered:idle.breathe()}
    Timer {id:hearts;interval:1250;onTriggered:idle.affectionate=false}
    Item {
        id:creature
        objectName:"idlePetBody"
        z:2
        width:idle.petWidth;height:width*99/134
        onWidthChanged:if (x+width>idle.width) x=idle.maxX
        onHeightChanged:if (y>idle.floorY) y=idle.floorY
        Item {
            anchors.fill:parent
            transform:Translate {y:idle.bob}
            Rectangle {
                anchors.horizontalCenter:parent.horizontalCenter;anchors.bottom:parent.bottom
                width:parent.width*.48;height:width*.16;radius:height/2
                color:Qt.rgba(Ui.FieldStyle.petGlow.r,Ui.FieldStyle.petGlow.g,Ui.FieldStyle.petGlow.b,.23)
                opacity:idle.airborne ? .62 : 1
            }
            Loader {
                anchors.fill:parent
                scale:idle.pose==="sleep" && idle.motion ? .97+.035*Math.sin(idle.clock*2.05) : 1
                rotation:!idle.motion ? 0 : idle.dragging ? -17 : idle.pose==="spin"
                    ? (1-(idle.poseEnd-idle.clock)/1.6)*360
                    : idle.pose==="feed" ? 13+Math.sin(idle.clock*7)*16
                    : idle.pose==="scratch" ? Math.sin(idle.clock*13)*17
                    : idle.airborne ? idle.heading*(4+4*Math.sin(idle.clock*3.6)) : -7
                sourceComponent:idle.software ? flat : solid
            }
            Repeater {
                model:idle.pose==="sleep" && !idle.dragging ? 3 : 0
                Text {
                    required property int index
                    readonly property real drift:idle.motion ? (idle.clock*.45+index/3)%1 : index/3
                    x:parent.width*(.60+drift*.22)
                    y:parent.height*(.29-drift*.54)
                    opacity:Math.sin(Math.PI*drift)
                    text:index===0 ? "Z" : "z"
                    color:"#d3eff7";style:Text.Outline;styleColor:"#30243a"
                    font.bold:true;font.pixelSize:Math.round(parent.width*(.086+drift*.071))
                }
            }
            Text {
                objectName:"idlePetReaction"
                anchors.horizontalCenter:parent.horizontalCenter;anchors.top:parent.top
                text:idle.affectionate ? "♥  ♥" : idle.pose==="curious" ? "?" : idle.clock<idle.alertedUntil ? "!" : ""
                color:idle.affectionate ? "#ffa5bf" : "#ffe4a5";style:Text.Outline;styleColor:"#30243a"
                font.pixelSize:Math.max(1,Math.round(parent.width*.15));font.bold:true
            }
        }
        Component {
            id:solid
            PetPortrait3D {
                helper:idle.helper;clock:idle.clock;animate:idle.motion
                heading:idle.airborne ? idle.heading*35 : 15
                textureWidthLimit:900
                resting:!idle.dragging && !idle.airborne
            }
        }
        Component {
            id:flat
            ProjectedPet {
                helper:idle.helper;flap:idle.motion ? Math.sin(idle.clock*(idle.dragging ? 21 : 9)) : 0
                resting:!idle.dragging && !idle.airborne
                glowTint:Ui.FieldStyle.petGlow
                transform:Scale {origin.x:width/2;xScale:idle.heading<0 ? -1 : 1}
            }
        }
        MouseArea {
            id:pointer
            anchors.fill:parent;anchors.margins:parent.width*.11
            drag.target:creature
            drag.minimumX:0;drag.maximumX:idle.maxX
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
            width:Math.max(64,idle.petWidth*.26);height:width*.54
            x:Math.min(idle.width-width,Math.max(0,horizontal*idle.width-width/2))
            y:ground
            readonly property real ground:Math.max(0,idle.height-idle.floorInset-height)
            property bool landed:false
            onGroundChanged:if (landed) y=ground
            SequentialAnimation {
                running:mark.visible && idle.roaming && !mark.landed
                ScriptAction {script:mark.y=mark.dropY}
                NumberAnimation {target:mark;property:"y";to:mark.ground;duration:620;easing.type:Easing.InQuad}
                ScriptAction {script:mark.landed=true}
            }
            Repeater {
                model:mark.landed ? 7 : 1
                Rectangle {
                    required property int index
                    x:mark.landed ? mark.width*(.13+((index*13)%39)*.015) : mark.width*.47
                    y:mark.landed ? mark.height*(.29+((index*5)%13)*.034) : 0
                    width:mark.landed ? mark.width*(.16+index%3*.078) : mark.width*.13
                    height:mark.landed ? mark.height*(.15+index%3*.075) : mark.height*.57
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

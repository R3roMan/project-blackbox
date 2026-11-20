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
    property string perchMode:"desktop"
    property var perch:null
    property string landedOn:""
    property real nextLanding:2
    property real nextPerchCheck:0
    property int perchIndex:0
    property real poseScale:1
    property real originScale:1
    property real destinationScale:1
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
    property string speech:""
    property string draftText:""
    property string carriedTitle:""
    property int giftCount:0
    property var routePoints:[]
    property real routeSpeed:1
    property string routeAnimation:""
    property real actionUntil:0
    signal attention(string type)
    signal carriedRequested()
    signal giftRequested()
    readonly property int droppingCount:marks.count
    property bool dragging:pointer.drag.active
    property double lastTick:0
    ListModel {id:marks}
    readonly property real floorY:Math.max(0,height-floorInset-creature.height-6)
    readonly property real petWidth:Math.min(width*.36,Math.max(190,(height-floorInset)*.31))
    readonly property real maxX:Math.max(0,width-creature.width)
    readonly property string actionArt:routeAnimation || pose
    readonly property bool airborne:["flight","landing","curious","spin"].includes(pose)
    readonly property real bob:!motion || !airborne || dragging ? 0
        : creature.height*.056*(Math.sin(clock*8)+.38*Math.sin(clock*16-1))

    function observePointer(x,y) {
        if (x<0 || y<0 || x>width || y>height) return
        cursor=Qt.point(x,y)
        cursorSeen=clock
    }
    function chirp() {audio.item?.play("idle-chirp",.58)}
    function say(text) {speech=text;if (text) speechTimer.restart()}
    function transformInto(form) {
        helper=form
        perform("surprise",1.2)
    }
    function perform(next,seconds) {
        routePoints=[]
        routeAnimation=""
        perch=null
        landedOn=""
        pose=next
        actionUntil=clock+seconds
        if (next==="inside") poseScale=.53
        else if (next!=="typing") poseScale=1
    }
    function flyTo(x,y,seconds=1.8) {
        routePoints=[]
        routeAnimation=""
        actionUntil=0
        perch=null
        landedOn=""
        beginFlight(x-petWidth*.5,y-petWidth*.35,"flight",seconds)
    }
    function route(points,seconds,animation="") {
        routePoints=points
        routeAnimation=animation
        routeSpeed=seconds
        perch=null
        landedOn=""
        actionUntil=0
        advanceRoute()
    }
    function advanceRoute() {
        if (!routePoints.length) {routeAnimation="";return false}
        const next=routePoints[0]
        routePoints=routePoints.slice(1)
        beginFlight(width*next[0]-petWidth*.5,height*next[1]-petWidth*.34,"flight",routeSpeed)
        return true
    }
    function sweep() {
        for (let i=marks.count-1;i>=0;--i)
            if (marks.get(i).spotFront===front) marks.remove(i)
    }
    function reload() {
        const available=Pets.pets.filter(pet=>pet.id!==helper.id && !pet.tarot)
        helper=available[Math.floor(Math.random()*available.length)]
        wander()
    }
    function beginFlight(x,y,next,seconds,scale=1) {
        const widthAtLanding=petWidth*scale
        origin=Qt.point(creature.x,creature.y)
        originScale=poseScale
        destinationScale=scale
        destination=Qt.point(Math.max(0,Math.min(width-widthAtLanding,x)),
            Math.max(0,Math.min(height-floorInset-widthAtLanding*99/134,y)))
        if (Math.abs(destination.x-origin.x)>8) heading=destination.x>origin.x ? 1 : -1
        arrival=next
        pose=next==="flight" ? "flight" : "landing"
        flightStart=clock
        flightDuration=helper.id==="chicken" ? seconds*.68 : seconds
        poseEnd=clock+flightDuration
    }
    function wander() {
        if (dragging) return
        actionUntil=0
        routePoints=[]
        routeAnimation=""
        perch=null
        landedOn=""
        beginFlight(Math.max(0,width-petWidth)*(.08+Math.random()*.84),floorY*(.13+Math.random()*.67),"flight",3.2+Math.random()*2.4)
    }
    function perchPoint(surface) {
        const widthAtRest=petWidth
        const x=Math.max(0,Math.min(width-widthAtRest,surface.x+surface.width/2-widthAtRest/2))
        return {x,y:Math.max(0,surface.y-widthAtRest*.445),scale:widthAtRest/petWidth}
    }
    function chooseLanding(next,preferSurface=false) {
        const candidates=(typeof perchLookup==="function" ? perchLookup() : []).filter(candidate=>candidate.width>0)
        if (candidates.length && (preferSurface || Math.random()<.9)) {
            perch=candidates[perchIndex++%candidates.length]
            const target=perchPoint(perch)
            landedOn=""
            nextPerchCheck=clock+.55
            beginFlight(target.x,target.y,next,2.3+Math.random()*.8,target.scale)
        } else {
            perch=null
            landedOn=""
            beginFlight(Math.max(0,width-petWidth)*(.08+Math.random()*.84),Math.max(0,height-floorInset-petWidth*99/134-6),
                next,2.5+Math.random()*1.4)
        }
        nextLanding=clock+12+Math.random()*7
    }
    function followPerch() {
        if (!perch || clock<nextPerchCheck) return
        nextPerchCheck=clock+.55
        const current=perchLookup()?.find(surface=>surface.key===perch.key)
        if (!current) {wander();return}
        const target=perchPoint(current)
        perch=current
        destination=Qt.point(target.x,target.y)
        destinationScale=target.scale
        if (!airborne) {
            poseScale=target.scale
            creature.x=target.x
            creature.y=target.y
        }
    }
    function leaveDropping() {
        let count=0
        for (let i=0;i<marks.count;++i) count+=Number(marks.get(i).spotFront===front)
        if (count<30 && marks.count<120) marks.append({spotFront:front,
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
            attention("caught")
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
        if (clock<actionUntil) return
        if (actionUntil) {actionUntil=0;wander();return}
        followPerch()
        if (pose==="curious") {chase(dt);return}
        if (pose==="flight" || pose==="landing") {
            const progress=Math.min(1,(clock-flightStart)/flightDuration)
            const eased=progress*progress*(3-2*progress)
            poseScale=originScale+(destinationScale-originScale)*eased
            creature.x=Math.min(maxX,origin.x+(destination.x-origin.x)*eased)
            creature.y=Math.max(0,Math.min(floorY,origin.y+(destination.y-origin.y)*eased
                -(motion ? Math.sin(progress*Math.PI)*creature.height*(pose==="landing" ? .23 : .47) : 0)))
            if (progress<1) return
            if (advanceRoute()) return
            if (pose==="landing") {
                pose=arrival
                landedOn=perch?.kind || ""
                poseEnd=clock+(pose==="sleep" ? 23+Math.random()*15 : 4.5+Math.random()*3)
                return
            }
        } else if (clock<poseEnd) return
        const roll=Math.random()
        if (pose==="flight" && clock>=nextLanding) chooseLanding(roll<.16 ? "sleep" : roll<.56 ? "feed" : "scratch",true)
        else if (!airborne) wander()
        else if (clock>curiosityReady && clock-cursorSeen<8 && roll<.25) startCuriosity()
        else if (roll<.18) chooseLanding("sleep")
        else if (roll<.31) chooseLanding("feed")
        else if (roll<.43) chooseLanding("scratch")
        else if (roll<.51 && motion && pose==="flight") {pose="spin";poseEnd=clock+1.6}
        else {
            if (pose==="flight" && roll>.86) leaveDropping()
            wander()
        }
    }
    onFrontChanged:if (roaming && !dragging) {nextLanding=clock+2;wander()}
    onPerchModeChanged:if (roaming && !dragging) {nextLanding=clock+1;wander()}
    onDraggingChanged:if (dragging) {chirp();attention("drag")} else wander()
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
    Timer {id:speechTimer;interval:5300;onTriggered:idle.speech=""}
    Timer {id:hearts;interval:1250;onTriggered:idle.affectionate=false}
    Item {
        id:creature
        objectName:"idlePetBody"
        z:2
        width:idle.petWidth*idle.poseScale;height:width*99/134
        onWidthChanged:if (x+width>idle.width) x=idle.maxX
        onHeightChanged:if (y>idle.floorY) y=idle.floorY
        Item {
            anchors.fill:parent
            transform:Translate {
                x:["sneak","strut","vine"].includes(idle.pose) ? Math.sin(idle.clock*4)*creature.width*.19 : 0
                y:idle.bob+(["hop","dance","surprise","cheer"].includes(idle.pose) ? -Math.abs(Math.sin(idle.clock*7))*creature.height*.18 : 0)
            }
            Rectangle {
                visible:!!idle.carriedTitle
                anchors.horizontalCenter:parent.horizontalCenter
                y:parent.height*.67
                width:parent.width*.14;height:width*.82
                rotation:Math.sin(idle.clock*7)*9
                radius:4;color:"#e1d3ac";border.color:"#513e38"
                Text {anchors.centerIn:parent;text:"▤";font.pixelSize:parent.height*.7;color:"#57464a"}
            }
            Rectangle {
                anchors.horizontalCenter:parent.horizontalCenter;anchors.bottom:parent.bottom
                anchors.bottomMargin:parent.height*.34
                width:parent.width*.40;height:width*.125;radius:height/2
                color:"transparent"
                opacity:idle.airborne ? 0 : .82
                Behavior on opacity {NumberAnimation {duration:250}}
                Repeater {
                    model:3
                    Rectangle {
                        required property int index
                        anchors.centerIn:parent
                        width:parent.width*(1-index*.17);height:parent.height*(1-index*.22)
                        radius:height*.5
                        color:Qt.rgba(Ui.FieldStyle.petGlow.r,Ui.FieldStyle.petGlow.g,Ui.FieldStyle.petGlow.b,.065+index*.024)
                    }
                }
            }
            Loader {
                anchors.fill:parent
                scale:idle.pose==="sleep" && idle.motion ? .97+.035*Math.sin(idle.clock*2.05) : 1
                rotation:!idle.motion ? 0 : idle.dragging ? -17 : idle.pose==="spin"
                    ? (1-(idle.poseEnd-idle.clock)/1.6)*360
                    : idle.pose==="feed" ? 13+Math.sin(idle.clock*7)*16
                    : idle.pose==="scratch" || idle.pose==="feathers" || idle.pose==="shake" ? Math.sin(idle.clock*13)*17
                    : idle.pose==="bow" || idle.pose==="peck" ? 18+Math.sin(idle.clock*8)*16
                    : idle.pose==="dance" || idle.pose==="strut" || idle.pose==="sing" ? Math.sin(idle.clock*10)*14
                    : idle.pose==="sulk" ? -22 : idle.pose==="vine" ? Math.sin(idle.clock*5)*25
                    : idle.pose==="wave" || idle.pose==="salute" ? Math.sin(idle.clock*8)*9
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
                idlePose:idle.actionArt
                heading:idle.airborne ? idle.heading*35 : 15
                textureWidthLimit:900
                resting:!idle.dragging && !idle.airborne
            }
        }
        Component {
            id:flat
            ProjectedPet {
                helper:idle.helper;idlePose:idle.actionArt;flap:idle.motion ? Math.sin(idle.clock*(idle.dragging ? 21 : 9)) : 0
                resting:!idle.dragging && !idle.airborne
                glowTint:Ui.FieldStyle.petGlow
                transform:Scale {origin.x:width/2;xScale:idle.heading<0 ? -1 : 1}
            }
        }
        Column {
            z:5
            anchors.horizontalCenter:parent.horizontalCenter
            y:creature.y<62 ? creature.height*.79 : -height-3
            spacing:4
            Rectangle {
                visible:!!idle.speech || !!idle.draftText
                width:Math.min(310,Math.max(105,bubble.implicitWidth+19))
                height:bubble.implicitHeight+16
                radius:9;color:"#ef211928";border.color:"#aa7969"
                Text {
                    id:bubble
                    anchors.left:parent.left;anchors.right:parent.right
                    anchors.margins:9;anchors.verticalCenter:parent.verticalCenter
                    color:"#fff2e6";wrapMode:Text.Wrap;font.pixelSize:14
                    text:idle.draftText ? "$ "+idle.draftText+"▍" : idle.speech
                    textFormat:Text.PlainText
                }
            }
            Repeater {
                model:[idle.carriedTitle, idle.giftCount ? "★ Gift" : ""]
                Rectangle {
                    required property string modelData
                    required property int index
                    visible:!!modelData
                    width:Math.min(205,card.implicitWidth+21);height:30;radius:5
                    color:"#342839";border.color:"#bc8e6e"
                    Text {id:card;anchors.centerIn:parent;text:parent.modelData;color:"#ffeac6";elide:Text.ElideRight;width:parent.width-13}
                    MouseArea {anchors.fill:parent;cursorShape:Qt.PointingHandCursor
                        onClicked:if (parent.index===0) idle.carriedRequested();else idle.giftRequested()}
                }
            }
        }
        MouseArea {
            id:pointer
            anchors.fill:parent;anchors.margins:parent.width*.11
            drag.target:creature
            drag.minimumX:0;drag.maximumX:idle.maxX
            drag.minimumY:0;drag.maximumY:idle.floorY
            cursorShape:pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            onClicked:{idle.affectionate=true;hearts.restart();idle.attention("click")}
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

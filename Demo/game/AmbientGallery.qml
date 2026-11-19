import QtQuick
import "../../V0.1/kde/contents/ui" as Template
import "Scenery.js" as Scenery
import "Controls.js" as Controls

Template.Scene {
    id:gallery
    durationMs:620
    showTransitionCaption:false
    roomArtwork:({shrine:Scenery.asset("front"),media:Scenery.asset("left"),lab:Scenery.asset("right"),
        sky:Scenery.asset("up"),abyss:Scenery.asset("down")})
    property date localTime:new Date()
    property double cycleOrigin:Date.now()
    property int phaseMinutes:10
    property int sceneryDetail:1
    property var forecast:Scenery.idleWeather(localTime,(localTime.getTime()-cycleOrigin)/1000,phaseMinutes)
    property var labAppearance:({})
    property bool mouseLook:false
    property Item pointerSurface:null
    property rect turnArea:Qt.rect(0,0,width,height)
    readonly property string liveFront:Scenery.rooms[room] || "front"
    property string controlBindings:"{}"
    readonly property var bindings:Controls.read(controlBindings)
    navigationKeyHandler:function(event) {
        return Controls.action(gallery.bindings,Controls.navigation,event) || ""
    }
    property bool escapeBack:false
    property string previousRoom:"shrine"
    property string committedRoom:"shrine"
    property int mouseEdge:-1
    onRoomChanged:{
        previousRoom=committedRoom
        committedRoom=room
        if (viewedRoom!=="lab") labAppearance=({})
    }
    Shortcut {
        sequences:Controls.sequences(gallery.bindings,"pause");context:Qt.WindowShortcut
        enabled:gallery.escapeBack && gallery.visible && gallery.exposed && gallery.enabled
            && !gallery.drawerOpen && !gallery.clean && !gallery.moving && gallery.room!=="shrine"
        onActivated:gallery.go(gallery.previousRoom)
    }
    HoverHandler {
        parent:gallery.pointerSurface || gallery
        enabled:gallery.mouseLook && gallery.exposed && !gallery.drawerOpen && !gallery.clean
        acceptedDevices:PointerDevice.Mouse | PointerDevice.TouchPad
        onPointChanged:{
            if (gallery.moving) return
            const area=gallery.turnArea
            const position=gallery.mapFromItem(parent,point.position.x,point.position.y)
            const gaps=[position.x-area.x,area.x+area.width-position.x,
                position.y-area.y,area.y+area.height-position.y]
            const distance=Math.min(...gaps)
            if (distance>28) {
                gallery.mouseEdge=-1
            } else if (distance>=0 && distance<17) {
                const edge=gaps.indexOf(distance)
                if (gallery.mouseEdge!==edge) {
                    gallery.mouseEdge=edge
                    gallery.move(["left","right","up","down"][edge])
                }
            }
        }
    }
    readonly property string viewedRoom:destination || room
    onViewedRoomChanged: {
        if (viewedRoom==="lab") labAppearance=Scenery.labVisit()
        else if (room!=="lab") labAppearance=({})
    }
    Timer {
        running:gallery.exposed && gallery.visible && !gallery.coverDemo
        interval:1000;repeat:true;triggeredOnStart:true
        onTriggered:gallery.localTime=new Date()
    }
    artworkView:Component {
        WallpaperTurn {
            artDirectory:Qt.resolvedUrl("../../V0.1/kde/contents/images/")
            frontId:Scenery.rooms[gallery.destination || gallery.room] || "front"
            previousFront:Scenery.rooms[gallery.room] || "front"
            direction:gallery.lookDirection || (frontId==="down" ? "down" : "up")
            progress:gallery.moving ? gallery.progress : 1
            lab:false
            sources:{
                const files={}
                for (const key of Object.keys(Scenery.rooms)) files[Scenery.rooms[key]]=gallery.artFor(key)
                return files
            }
            phase:gallery.forecast.phase;weather:gallery.forecast.weather
            clock:gallery.frames/Math.max(1,gallery.ambientFps)
            solarTime:gallery.forecast.solarTime; motion:gallery.ambient
            windy:gallery.forecast.windy;cloudy:gallery.forecast.cloudy;swarm:gallery.forecast.swarm
            detail:gallery.performance ? 0 : gallery.sceneryDetail
            labAppearance:gallery.labAppearance
            weatherParticles:true;continuousWeather:true;perspectiveSky:true
        }
    }

    roomLighting:Component {
        Item {
            id:litRoom
            readonly property string front:Scenery.rooms[parent.sceneRoom] || ""
            readonly property real clock:gallery.frames/Math.max(1,gallery.ambientFps)
            RoomAtmosphere {
                anchors.fill:parent
                front:litRoom.front;custom:litRoom.parent.customImage
                phase:gallery.forecast.phase;weather:gallery.forecast.weather
                solarTime:gallery.forecast.solarTime
                windy:gallery.forecast.windy;cloudy:gallery.forecast.cloudy;swarm:gallery.forecast.swarm
                motion:gallery.ambient;clock:litRoom.clock;detail:gallery.performance ? 0 : gallery.sceneryDetail
                labAppearance:gallery.labAppearance
                weatherParticles:true
            }
        }
    }
}

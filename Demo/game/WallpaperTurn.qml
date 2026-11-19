import QtQuick
import "Rules.js" as Rules
import "Scenery.js" as Scenery
import "../../V0.1/kde/contents/ui/ViewTurn.js" as ViewTurn
import "../../V0.1/kde/contents/ui" as Gallery

Item {
    id:backdrop
    required property url artDirectory
    required property string frontId
    required property string previousFront
    required property string direction
    required property real progress
    required property bool lab
    property var sources:({})
    property string phase:"daytime"
    property string weather:"clear"
    property string lightingWeather:weather
    property bool cloudy:false
    property bool windy:false
    property real clock:0
    property real solarTime:clock
    property bool motion:true
    property bool swarm:false
    property bool weatherParticles:false
    property var labAppearance:({})
    property int detail:1
    property string framing:"fill"
    property int quality:0
    property real zoom:1
    property string transitionStyle:"cinematic"
    property real transitionStrength:1
    readonly property string activeFront:lab ? "right" : frontId
    readonly property bool moving:progress<1 && !lab && previousFront!==frontId
    readonly property bool abyssTransition:moving && (activeFront==="down" || previousFront==="down")
    readonly property bool descending:abyssTransition && transitionStyle==="cinematic"
    readonly property bool rotating:moving && !abyssTransition && transitionStyle==="cinematic"
    readonly property real sampleScale:Math.min(Math.max(1,Screen.devicePixelRatio),quality>0
        ? quality/Math.max(1,height) : 8192/Math.max(1,width))
    function defaultFor(front) {return Scenery.asset(front) || Qt.resolvedUrl(String(artDirectory)+Rules.front(front).art)}
    clip:true
    Repeater {
        id:panels
        model:["front","left","right","up","down"]
        delegate:Item {
            id:panel
            required property string modelData
            property alias surface:wall
            readonly property bool incoming:modelData===backdrop.activeFront
            readonly property bool inView:incoming || backdrop.moving && modelData===backdrop.previousFront
            width:backdrop.width;height:backdrop.height
            clip:true
            // During a dissolve the departing view stays opaque beneath the arrival.
            z:incoming ? 1 : 0
            opacity:!inView ? 0 : backdrop.moving && !backdrop.rotating && incoming ? backdrop.progress : 1
            readonly property var descent:backdrop.descending ? ViewTurn.descent(height,backdrop.progress,incoming,
                backdrop.previousFront==="down",backdrop.transitionStrength) : ({scale:1,y:0})
            transform:Matrix4x4 {
                matrix:backdrop.rotating ? ViewTurn.panel(panel.width,panel.height,backdrop.direction,
                    backdrop.progress,panel.incoming,backdrop.transitionStrength) : ViewTurn.identity()
            }
            Image {
                id:wall
                objectName:panel.incoming ? "activeWallpaper" : ""
                width:parent.width;height:parent.height
                anchors.centerIn:parent
                anchors.verticalCenterOffset:panel.descent.y
                readonly property url fallback:backdrop.defaultFor(panel.modelData)
                readonly property url requested:backdrop.sources[panel.modelData] || fallback
                readonly property real distanceScale:panel.modelData==="down" && String(source)===String(fallback)
                    ? Math.min(.75,1060/Math.max(1,width*backdrop.sampleScale*backdrop.zoom)) : 1
                property bool failed:false
                onRequestedChanged:failed=false
                onStatusChanged:if(status===Image.Error && String(source)!==String(fallback))failed=true
                source:failed ? fallback : requested
                smooth:true;mipmap:true
                scale:backdrop.zoom*panel.descent.scale
                sourceSize:Qt.size(Math.max(1,Math.round(width*backdrop.sampleScale*backdrop.zoom*distanceScale)),
                    Math.max(1,Math.round(height*backdrop.sampleScale*backdrop.zoom*distanceScale)))
                fillMode:backdrop.framing==="stretch" ? Image.Stretch : backdrop.framing==="fit" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                Loader {
                    anchors.centerIn:parent
                    width:wall.paintedWidth;height:wall.paintedHeight
                    active:wall.status===Image.Ready
                    sourceComponent:RoomAtmosphere {
                        front:panel.modelData;phase:backdrop.phase;weather:backdrop.weather
                        lightingWeather:backdrop.lightingWeather
                        custom:String(wall.source)!==String(wall.fallback)
                        cloudy:backdrop.cloudy;windy:backdrop.windy
                        clock:panel.inView ? backdrop.clock : Math.floor(backdrop.clock/5)*5
                        solarTime:panel.inView ? backdrop.solarTime : Math.floor(backdrop.solarTime/5)*5
                        motion:backdrop.motion && panel.inView
                        weatherParticles:backdrop.weatherParticles && panel.inView
                        detail:backdrop.detail;swarm:backdrop.swarm;labAppearance:backdrop.labAppearance
                    }
                }
            }
        }
    }
    Gallery.TurnJoin {
        anchors.fill:parent;z:2
        active:backdrop.rotating
        direction:backdrop.direction;progress:backdrop.progress
        lightingKey:backdrop.phase+"/"+backdrop.lightingWeather
        outgoing:active ? panels.itemAt(panels.model.indexOf(backdrop.previousFront))?.surface || null : null
    }
    Gallery.DescentShade {
        anchors.fill:parent;z:2
        progress:backdrop.descending ? backdrop.progress : 0
        strength:backdrop.transitionStrength
    }
}

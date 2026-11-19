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
    property bool continuousWeather:false
    property bool perspectiveSky:false
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
    readonly property bool skyTurn:moving && (activeFront==="up" || previousFront==="up")
    readonly property bool rotating:moving && !abyssTransition && (!skyTurn || perspectiveSky) && transitionStyle==="cinematic"
    readonly property real sampleScale:Math.min(Math.max(1,Screen.devicePixelRatio),quality>0
        ? quality/Math.max(1,height) : 8192/Math.max(1,width))
    function defaultFor(front) {return Scenery.asset(front) || Qt.resolvedUrl(String(artDirectory)+Rules.front(front).art)}
    function weatherAcross(fn) {
        const current=fn(activeFront)
        if (!moving) return current
        const old=fn(previousFront)
        return old+(current-old)*progress
    }
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
            readonly property real skyTravel:backdrop.skyTurn ? (incoming ? 1-backdrop.progress : backdrop.progress) : 0
            readonly property var descent:backdrop.descending ? ViewTurn.descent(height,backdrop.progress,incoming,
                backdrop.previousFront==="down",backdrop.transitionStrength) : backdrop.skyTurn && !backdrop.rotating
                ? ({scale:1+skyTravel*.22,y:height*skyTravel*.085*(incoming===(backdrop.direction==="up") ? -1 : 1)})
                : ({scale:1,y:0})
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
                readonly property real pixelScale: {
                    const wanted=backdrop.sampleScale*backdrop.zoom
                    const stock=String(source)===String(fallback)
                    const ceiling=stock ? (panel.modelData==="down" ? 1060 : panel.modelData==="up" ? 1600 : 1672) : 3840
                    return Math.min(wanted*(stock && panel.modelData==="down" ? .75 : 1),ceiling/Math.max(1,width))
                }
                property bool failed:false
                onRequestedChanged:failed=false
                onStatusChanged:if(status===Image.Error && String(source)!==String(fallback))failed=true
                source:failed ? fallback : requested
                smooth:true;mipmap:true
                scale:backdrop.zoom*panel.descent.scale
                sourceSize:Qt.size(Math.max(1,Math.round(width*pixelScale)),Math.max(1,Math.round(height*pixelScale)))
                fillMode:backdrop.framing==="stretch" ? Image.Stretch : backdrop.framing==="fit" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
                Loader {
                    anchors.centerIn:parent
                    width:wall.paintedWidth;height:wall.paintedHeight
                    active:wall.status===Image.Ready && (!backdrop.continuousWeather || panel.inView)
                    sourceComponent:RoomAtmosphere {
                        front:panel.modelData;phase:backdrop.phase;weather:backdrop.weather
                        lightingWeather:backdrop.lightingWeather
                        custom:String(wall.source)!==String(wall.fallback)
                        cloudy:backdrop.cloudy;windy:backdrop.windy
                        clock:panel.inView ? backdrop.clock : Math.floor(backdrop.clock/5)*5
                        solarTime:panel.inView ? backdrop.solarTime : Math.floor(backdrop.solarTime/5)*5
                        motion:backdrop.motion && panel.inView
                        weatherParticles:backdrop.weatherParticles && !backdrop.continuousWeather && panel.inView
                        detail:backdrop.detail;swarm:backdrop.swarm;labAppearance:backdrop.labAppearance
                    }
                }
            }
        }
    }
    Loader {
        anchors.fill:parent;z:3
        active:backdrop.weatherParticles && backdrop.continuousWeather && backdrop.lightingWeather!=="clear"
        sourceComponent:WeatherFX {
            condition:backdrop.lightingWeather
            time:backdrop.clock;motion:backdrop.motion;ultra:backdrop.detail===3
            particleResolution:backdrop.detail===3 ? 1320 : 920
            fogDensity:backdrop.weatherAcross(Scenery.fogDensity)
            nearVisibility:backdrop.weatherAcross(Scenery.fogNearVisibility)
            opacity:condition==="fog" ? 1 : backdrop.weatherAcross(front=>Scenery.roomWeather(condition,front)==="clear" ? 0 : front==="right" ? .45 : 1)
        }
    }
    Gallery.TurnJoin {
        anchors.fill:parent;z:2
        active:backdrop.rotating
        direction:backdrop.direction;progress:backdrop.progress
        lightingKey:backdrop.phase+"/"+backdrop.lightingWeather
        seamTint:backdrop.continuousWeather && backdrop.lightingWeather==="fog" ? "#a6acb4" : "transparent"
        outgoing:active ? panels.itemAt(panels.model.indexOf(backdrop.previousFront))?.surface || null : null
    }
    Gallery.DescentShade {
        anchors.fill:parent;z:2
        progress:backdrop.descending ? backdrop.progress : 0
        strength:backdrop.transitionStrength
    }
}

import QtQuick
import "../../V0.1/kde/contents/ui" as Template
import "Scenery.js" as Scenery

Template.Scene {
    id:gallery
    roomArtwork:({shrine:Scenery.asset("front"),media:Scenery.asset("left"),lab:Scenery.asset("right"),
        sky:Scenery.asset("up"),abyss:Scenery.asset("down")})
    property date localTime:new Date()
    property int sceneryDetail:1
    property var forecast:Scenery.idleWeather(localTime)
    property var labAppearance:({})
    readonly property string viewedRoom:destination || room
    onViewedRoomChanged: {
        if (viewedRoom==="lab") labAppearance=Scenery.labVisit()
        else if (room!=="lab") labAppearance=({})
    }
    onRoomChanged:if (viewedRoom!=="lab") labAppearance=({})
    Timer {
        running:gallery.exposed && gallery.visible && !gallery.coverDemo
        interval:60000;repeat:true;triggeredOnStart:true
        onTriggered:gallery.localTime=new Date()
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
            }
            WeatherFX {
                anchors.fill:parent
                condition:litRoom.front==="down" ? "clear" : gallery.forecast.weather
                opacity:litRoom.front==="right" ? .32 : 1
                motion:gallery.ambient;time:litRoom.clock
            }
        }
    }
}

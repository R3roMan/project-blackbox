import QtQuick
import "Conditions.js" as Conditions

Item {
    id:room
    required property string front
    required property string phase
    required property string weather
    required property real clock
    property real solarTime:clock
    property string lightingWeather:weather
    property bool custom:false
    property bool cloudy:false
    property bool windy:false
    property bool motion:true
    property bool swarm:false
    property var labAppearance:({})
    property int detail:1
    readonly property var sky:Conditions.sky(phase,solarTime,front)
    Loader {
        anchors.fill:parent
        active:!room.custom
        sourceComponent:LandscapeEffects {
            front:room.front;phase:room.phase;weather:room.weather
            clock:room.clock;solarTime:room.solarTime;cloudy:room.cloudy;windy:room.windy;motion:room.motion
            detail:room.detail;specimen:!!room.labAppearance.specimen;bloody:!!room.labAppearance.bloody;swarm:room.swarm
        }
    }
    Loader {
        anchors.fill:parent
        active:room.custom
        sourceComponent:SkyDome {
            sky:room.sky;frontId:room.front;night:room.phase
            sunTint:"#fff2c7";customWall:true;projected:true
            cloudy:room.cloudy;windy:room.windy;motion:room.motion;clock:room.clock
        }
    }
    Loader {
        anchors.fill:parent
        active:room.front==="down" || room.front==="up" && Conditions.isNight(room.phase)
        sourceComponent:WallpaperAtmosphere {
            front:room.front;clock:room.clock;night:room.sky.dark;motion:room.motion;detail:room.detail
        }
    }
    Loader {
        anchors.fill:parent
        active:!room.custom && room.front==="up" && Conditions.isNight(room.phase)
        sourceComponent:Item {
            LunarDisc {redNight:room.phase==="bloodMoon";orbitX:room.sky.moonX;orbitY:room.sky.moonY}
        }
    }
    WeatherFX {
        anchors.fill:parent
        sky:true
        condition:room.front==="down" && room.lightingWeather!=="incursion" ? "clear" : room.lightingWeather
        opacity:room.front==="right" && condition!=="incursion" ? .55 : 1
        time:room.clock
        motion:room.motion
    }
}

import QtQuick
import "Conditions.js" as Conditions
import "Scenery.js" as Scenery

Item {
    id:room
    required property string front
    required property string phase
    required property string weather
    required property real clock
    property real solarTime:clock
    property string lightingWeather:weather
    property bool custom:false
    property bool weatherParticles:false
    property bool cloudy:false
    property bool windy:false
    property bool motion:true
    property bool swarm:false
    property var labAppearance:({})
    property int detail:1
    readonly property string localWeather:Scenery.roomWeather(lightingWeather,front)
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
        active:room.custom && room.front!=="down"
        sourceComponent:SkyDome {
            sky:room.sky;frontId:room.front;night:room.phase
            sunTint:"#fff2c7";customWall:true;projected:true
            cloudy:room.cloudy;windy:room.windy;motion:room.motion;clock:room.clock
        }
    }
    Rectangle {
        anchors.fill:parent
        visible:room.front==="down"
        gradient:Gradient {
            GradientStop {position:0; color:"#a1080913"}
            GradientStop {position:.33; color:"#950e0a1a"}
            GradientStop {position:.67; color:"#65090411"}
            GradientStop {position:1; color:"#8c05050d"}
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
    Rectangle {
        anchors.fill:parent
        visible:room.front==="down" && ["cloudy","heatwave"].includes(room.localWeather)
        gradient:Gradient {
            GradientStop {position:0; color:room.localWeather==="heatwave" ? "#306a3b29" : "#3d383e53"}
            GradientStop {position:1; color:room.localWeather==="heatwave" ? "#6d8a3a27" : "#172f3240"}
        }
    }
    Loader {
        anchors.fill:parent
        active:room.weatherParticles && room.localWeather!=="clear"
        sourceComponent:WeatherFX {
            condition:room.localWeather; time:room.clock; motion:room.motion
            opacity:room.front==="right" ? .45 : 1
        }
    }
    WeatherFX {
        anchors.fill:parent
        sky:true
        condition:room.localWeather
        nearVisibility:Scenery.fogNearVisibility(room.front)
        opacity:condition==="fog" ? (room.front==="left" ? .76 : room.front==="right" ? .94 : 1)
            : room.front==="right" && condition!=="incursion" ? .55 : 1
        time:room.clock
        motion:room.motion
    }
    Loader {
        anchors.fill:parent
        active:!room.custom && room.detail>0 && ["front","left"].includes(room.front)
        sourceComponent:ShrineLight {
            front:room.front;phase:room.phase;weather:room.localWeather
            clock:room.clock;solarTime:room.solarTime;motion:room.motion
            windy:room.windy;cloudy:room.cloudy;detail:room.detail
        }
    }
}

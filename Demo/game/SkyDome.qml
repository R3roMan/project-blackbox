import QtQuick

Item {
    id: dome
    required property var sky
    required property string frontId
    required property string night
    required property color sunTint
    property bool customWall:false
    property bool cloudy:false
    property bool windy:false
    property real clock:0
    readonly property bool painted:!customWall && ["left","right","down"].includes(frontId)
    property bool projected:false
    property bool motion:true
    property real turn:1
    readonly property real horizon: frontId==="up" ? .89 : frontId==="down" ? .48 : 1

    Rectangle {
        anchors.fill:parent
        opacity:dome.painted ? 0 : (1-dome.sky.dark)*(1-dome.sky.warm)*.52*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:"#b74d9ce5"}
            GradientStop {position:.38;color:"#9b82c5f5"}
            GradientStop {position:.62;color:"#53cce8f9"}
            GradientStop {position:1;color:"#00eacd9e"}
        }
    }

    Rectangle {
        anchors.fill:parent
        opacity:dome.sky.abyss || dome.painted ? 0 : dome.sky.dark*.76*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:"#102544"}
            GradientStop {position:.56;color:"#182442"}
            GradientStop {position:1;color:"#160c28"}
        }
    }
    Rectangle {
        anchors.fill:parent
        opacity:dome.painted ? 0 : dome.sky.warm*.78*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:dome.night==="sunrise" ? "#a78aaadf" : "#a44c325e"}
            GradientStop {position:.44;color:dome.night==="sunrise" ? "#abf6b6a9" : "#b9cc555c"}
            GradientStop {position:.66;color:dome.night==="sunrise" ? "#caefd394" : "#ebef844f"}
            GradientStop {position:1;color:"#34261731"}
        }
    }
    Rectangle {
        anchors.fill:parent
        opacity:(dome.painted ? 0 : dome.sky.red)*(dome.frontId==="up" ? .88 : .42)
        gradient:Gradient {
            GradientStop {position:0;color:"#621c37"}
            GradientStop {position:.55;color:"#911f37"}
            GradientStop {position:1;color:"#270914"}
        }
    }
    Rectangle {
        anchors.fill:parent
        visible:!!dome.sky.abyss && !dome.painted
        gradient:Gradient {
            GradientStop {position:0;color:"#b6080713"}
            GradientStop {position:.64;color:"#99110b20"}
            GradientStop {position:1;color:"#bc06050a"}
        }
    }
    Item {
        id:sun
        objectName:"leftSkySun"
        readonly property real size:Math.min(dome.width,dome.height)*.246
        x:dome.width*dome.sky.sunX-width*.5
        y:dome.height*dome.sky.sunY-height*.5
        width:size;height:size
        visible:dome.customWall && dome.frontId==="left" && dome.sky.sun>.002
        opacity:dome.sky.sun*(.72+.28*dome.turn)
        Canvas {
            id:glow
            anchors.fill:parent
            onWidthChanged:requestPaint()
            onVisibleChanged:if (visible) requestPaint()
            Connections {target:dome;function onProjectedChanged(){glow.requestPaint()}}
            onPaint: {
                const c=getContext("2d"), mid=width*.5
                if (mid<=0) return
                c.reset();c.clearRect(0,0,width,height)
                const halo=c.createRadialGradient(mid,mid,mid*.14,mid,mid,mid)
                halo.addColorStop(0,"#ffffe3ad");halo.addColorStop(.29,"#edffc966")
                halo.addColorStop(.48,"#98ffaf5a");halo.addColorStop(.68,"#40ff9b47");halo.addColorStop(1,"transparent")
                c.fillStyle=halo;c.fillRect(0,0,width,height)
                if (!dome.projected) return
                c.fillStyle="#fff3c8";c.beginPath();c.arc(mid,mid,mid*.39,0,Math.PI*2);c.fill()
            }
        }
        Loader {
            anchors.fill:parent
            active:sun.visible && !dome.projected
            sourceComponent: SunOrb {turn:dome.sky.sunX*30; shade:dome.sunTint}
        }
    }
    LunarDisc {
        visible:dome.frontId==="up" && dome.sky.moon>.002
        opacity:dome.sky.moon*(.72+.28*dome.turn)
        redNight:dome.night==="bloodMoon"
        orbitX:dome.sky.moonX
        orbitY:dome.sky.moonY
    }
    Loader {
        anchors.fill:parent
        active:dome.cloudy && dome.frontId!=="down" && !dome.painted
        sourceComponent:LandscapeSky {
            front:dome.frontId==="up" ? "up" : "front"
            phase:dome.night
            cloudy:true
            cloudsOnly:true
            windy:dome.windy
            clock:dome.clock
            motion:dome.motion
        }
    }
}

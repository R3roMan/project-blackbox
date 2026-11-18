import QtQuick

Item {
    id: dome
    required property var sky
    required property string frontId
    required property string night
    required property color sunTint
    property bool projected:false
    property bool motion:true
    property real turn:1
    readonly property real horizon: frontId==="up" ? .89 : frontId==="down" ? .48 : 1

    Rectangle {
        anchors.fill:parent
        opacity:(1-dome.sky.dark)*(1-dome.sky.warm)*.56*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:"#ad6484ad"}
            GradientStop {position:.38;color:"#926f91ad"}
            GradientStop {position:.62;color:"#5ceac797"}
            GradientStop {position:1;color:"#00eacd9e"}
        }
    }

    Rectangle {
        anchors.fill:parent
        opacity:dome.sky.dark*.76*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:"#102544"}
            GradientStop {position:.56;color:"#182442"}
            GradientStop {position:1;color:"#160c28"}
        }
    }
    Rectangle {
        anchors.fill:parent
        opacity:dome.sky.warm*.45*dome.horizon
        gradient:Gradient {
            GradientStop {position:0;color:"#75162b67"}
            GradientStop {position:.44;color:"#b9d87455"}
            GradientStop {position:.66;color:"#ebde8651"}
            GradientStop {position:1;color:"#34261731"}
        }
    }
    Rectangle {
        anchors.fill:parent
        opacity:dome.sky.red*(dome.frontId==="up" ? .88 : .42)
        gradient:Gradient {
            GradientStop {position:0;color:"#621c37"}
            GradientStop {position:.55;color:"#911f37"}
            GradientStop {position:1;color:"#270914"}
        }
    }
    Item {
        id:sun
        objectName:"leftSkySun"
        readonly property real size:Math.min(dome.width,dome.height)*.246
        x:dome.width*dome.sky.sunX-width*.5
        y:dome.height*dome.sky.sunY-height*.5
        width:size;height:size
        visible:dome.frontId==="left" && dome.sky.sun>.002
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
}

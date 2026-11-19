import QtQuick
import "../ui" as Ui

Item {
    id:dial
    property real charge:0
    property int rounds:0
    property int capacity:0
    property string readout:""
    property string caption:""
    property color tint:"#ffcf9d"
    property bool warning:false
    implicitWidth:88
    implicitHeight:88
    Accessible.name:caption+" "+readout

    Canvas {
        id:ring
        anchors.fill:parent
        onAvailableChanged:requestPaint()
        onWidthChanged:requestPaint()
        onHeightChanged:requestPaint()
        Connections {
            target:dial
            function onChargeChanged(){ring.requestPaint()}
            function onRoundsChanged(){ring.requestPaint()}
            function onCapacityChanged(){ring.requestPaint()}
            function onWarningChanged(){ring.requestPaint()}
            function onTintChanged(){ring.requestPaint()}
        }
        onPaint:{
            const c=getContext("2d")
            c.reset()
            c.clearRect(0,0,width,height)
            const x=width/2,y=height/2,r=Math.max(0,Math.min(x,y)-6)
            const first=-Math.PI/2, span=Math.PI*2
            c.strokeStyle="#564858"
            c.lineWidth=2
            c.beginPath()
            c.arc(x,y,r,0,span)
            c.stroke()
            const bright=dial.warning ? "#ff7784" : dial.tint
            if (dial.capacity>0) {
                const step=span/dial.capacity
                c.lineWidth=Math.max(1,Math.min(5,r*step*.52))
                for (let i=0;i<dial.capacity;i++) {
                    const angle=first+i*step
                    c.strokeStyle=i<dial.rounds ? bright : "#423642"
                    c.beginPath()
                    c.moveTo(x+Math.cos(angle)*(r-7),y+Math.sin(angle)*(r-7))
                    c.lineTo(x+Math.cos(angle)*(r+1),y+Math.sin(angle)*(r+1))
                    c.stroke()
                }
            } else if (dial.charge>0) {
                c.strokeStyle=bright
                c.lineWidth=4
                c.lineCap="round"
                c.beginPath()
                c.arc(x,y,r,first,first+span*Math.min(1,dial.charge))
                c.stroke()
            }
        }
    }
    Column {
        anchors.centerIn:parent
        width:Math.max(0,parent.width-23)
        Text {
            width:parent.width; horizontalAlignment:Text.AlignHCenter; text:dial.readout
            color:dial.warning ? "#ff7784" : dial.tint; font.family:"IBM Plex Mono"; font.bold:true
            font.pixelSize:Ui.UiMetrics.text(dial.width<75 ? 14 : 23); fontSizeMode:Text.HorizontalFit; minimumPixelSize:10
        }
        Text {
            width:parent.width; horizontalAlignment:Text.AlignHCenter; text:dial.caption; visible:text.length>0
            color:"#d2bdce";font.family:"IBM Plex Mono";font.pixelSize:Ui.UiMetrics.text(9)
            elide:Text.ElideRight
        }
    }
}

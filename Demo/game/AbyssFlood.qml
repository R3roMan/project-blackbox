import QtQuick
import "../ui" as Ui
import "Conditions.js" as Conditions

Item {
    id: flood
    required property bool active
    required property real time
    required property bool motion
    required property bool warning
    objectName:"abyssFlood"
    readonly property int seconds: Math.max(0,Math.ceil(Conditions.abyssSeconds-time))
    readonly property real heightFraction: Math.min(1,.045+.955*time/Conditions.abyssSeconds)
    readonly property real pulse: motion ? .5+.5*Math.cos(time*7.7) : .7

    Loader {
        anchors.fill:parent
        active:flood.active || opacity>.01
        opacity:flood.active ? 1 : 0
        Behavior on opacity {NumberAnimation {duration:flood.motion ? 520 : 0}}
        sourceComponent:EffectCanvas {
            id: surface
            frameRate:16
            textureLimit:1120
            readonly property int beat: Math.floor(flood.time*16)
            onBeatChanged:requestPaint()
            onPaint: {
                const c=beginPaint()
                if (!c || width<1 || height<1) return
                c.clearRect(0,0,width,height)
                const clock=flood.motion ? beat/16 : 0
                const crest=height*(1-flood.heightFraction)
                function ripple(x) {
                    return crest-Math.pow(flood.heightFraction,.55)*height*.016
                        +Math.sin(x*.022+clock*2.55)*5+Math.cos(x*.067-clock*1.80)*2.8
                }
                const ink=c.createLinearGradient(0,crest-10,0,Math.max(crest-9,height))
                ink.addColorStop(0,"#d61a1024")
                ink.addColorStop(.14,"#f2080710")
                ink.addColorStop(1,"#ff020106")
                c.beginPath();c.moveTo(0,ripple(0))
                for (let x=0;x<=width+20;x+=20) c.lineTo(x,ripple(x))
                c.lineTo(width,height);c.lineTo(0,height);c.closePath()
                c.fillStyle=ink;c.fill()
                c.beginPath();c.moveTo(0,ripple(0))
                for (let x=0;x<=width+16;x+=16) c.lineTo(x,ripple(x))
                c.strokeStyle="#ac675078";c.lineWidth=2;c.stroke()
                for (let i=0;i<36;i++) {
                    const x=width*((.23+i*.61803399)%1)
                    const phase=(i*.215+clock*(.66+i%4*.12))%1
                    const radius=3+(i%5+1)*1.4+phase*5
                    const y=ripple(x)+(1-phase)*Math.min(height*flood.heightFraction*.48,75)-phase*5
                    c.globalAlpha=.12+Math.sin(phase*Math.PI)*.51
                    c.fillStyle="#21172b";c.strokeStyle="#675478";c.lineWidth=1.3
                    c.beginPath();c.arc(x,y,radius,0,Math.PI*2);c.fill();c.stroke()
                }
                c.globalAlpha=1
            }
        }
    }

    Column {
        visible:flood.active && flood.warning && flood.seconds>0
        width:parent.width*.78
        anchors.horizontalCenter:parent.horizontalCenter
        y:Math.max(135,parent.height*.24)
        spacing:4
        Text {
            objectName:"takeoverWarning"
            width:parent.width
            text:flood.seconds<=10 ? String(flood.seconds) : "ABYSSAL TAKEOVER"
            font.family:"Cormorant Garamond"
            font.pixelSize:Ui.UiMetrics.text(Math.max(30,Math.min(72,flood.height*.076)))
            font.weight:Font.Black
            horizontalAlignment:Text.AlignHCenter
            style:Text.Outline
            styleColor:"#130718"
            color:Qt.tint("#ce90ed",Qt.rgba(1,.78,.98,flood.pulse*.44))
            scale:1+flood.pulse*.035
        }
        Text {
            width:parent.width
            text:"Go to the Abyss and hold F to seal the rift"+(flood.seconds>10 ? "  ·  "+flood.seconds+"s left" : "")
            horizontalAlignment:Text.AlignHCenter
            wrapMode:Text.WordWrap
            color:"#f9e6ff"
            font.pixelSize:Ui.UiMetrics.text(13)
            font.family:"Inter"
            style:Text.Outline
            styleColor:"#100916"
        }
    }
}

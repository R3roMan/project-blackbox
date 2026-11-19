import QtQuick
import "../game" as Game

Game.EffectCanvas {
    id: sparks
    property bool animate:true
    property bool exposed:true
    property real clock:0
    textureLimit:1080
    frameRate:14
    onClockChanged:requestPaint()
    Timer {interval:71;repeat:true;running:sparks.visible && sparks.exposed && sparks.animate;onTriggered:sparks.clock+=.071}
    onPaint:{
        const c=beginPaint()
        if (!c || width<2) return
        c.clearRect(0,0,width,height)
        for (let i=0;i<51;i++) {
            const x=(.237+i*.61803399)%1*width
            const y=(.099+i*.75487766)%1*height*.39
            const size=(i%9===0 ? 1.7 : i%3===0 ? 1.05 : .64)*Math.max(.78,width/1420)
            c.globalAlpha=(.30+.63*Math.pow(.5+.5*Math.sin(i*6.17+clock*(.4+i%7*.21)),2))*(.36+.64*x/width)
            c.fillStyle=i%9===0 ? "#d3bdff" : i%4===0 ? "#b5ceff" : "#fff4de"
            c.fillRect(x,y,size*2,size*2)
            if (i%9===0) {
                c.globalAlpha*=.4
                c.fillRect(x-2,y+.8,2*size+4,1)
                c.fillRect(x+.8,y-2,1,2*size+4)
            }
        }
        for (let i=0;i<18;i++) {
            const u=((i*.381966+clock*(i%2 ? .006:.003))%1+.25)%1
            const x=u*width
            const y=height*(.49+((i*.8635+clock*.003)%1)*.47+Math.sin(clock*.69+i)*.02)
            const light=.48+.40*Math.sin(i+clock*(.6+i%5*.36))
            c.globalAlpha=light*.34
            c.fillStyle=i%4 ? "#dd964b" : "#c2b8e4"
            c.beginPath();c.arc(x,y,4.4,0,Math.PI*2);c.fill()
            c.globalAlpha=light
            c.fillStyle=i%4 ? "#ffdaad" : "#e4e1ff"
            c.beginPath();c.arc(x,y,1.3,0,Math.PI*2);c.fill()
        }
        c.globalAlpha=1
    }
}

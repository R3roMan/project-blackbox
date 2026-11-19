import QtQuick

EffectCanvas {
    id:swarm
    objectName:"nightFireflies"
    required property bool lakeside
    required property bool motion
    required property real clock
    required property int detail
    textureLimit:1152
    frameRate:14
    readonly property int beat:motion ? Math.floor(clock*frameRate) : 0
    onBeatChanged:requestPaint()
    onLakesideChanged:requestPaint()
    onPaint: {
        const c=beginPaint(), t=beat/frameRate
        c.clearRect(0,0,width,height)
        c.scale(width/768,height/432)
        const count=[16,26,36,44][Math.min(3,detail)]
        for(let i=0;i<count;i++) {
            const group=i%3, offset=i*2.39996
            const baseX=(lakeside ? [172,295,630] : [149,335,557])[group]
            const baseY=(lakeside ? [299,276,302] : [285,254,270])[group]
            const x=baseX+Math.sin(offset*13.41)*46+Math.sin(t*.38+group)*16+Math.cos(t*.9+i)*8
            const y=baseY+Math.cos(offset*11.22)*18+Math.cos(t*.56+group)*5+Math.sin(t*.77+offset)*5
            const pulse=Math.pow(Math.max(0,Math.sin(t*(.83+i%5*.08)+offset)+.1)/1.1,2)
            if (pulse<.05)continue
            const size=.65+i%4*.19
            const halo=c.createRadialGradient(x,y,0,x,y,4*size)
            halo.addColorStop(0,Qt.rgba(.79,.99,.37,pulse*.65));halo.addColorStop(1,"transparent")
            c.fillStyle=halo;c.fillRect(x-size*4,y-size*4,size*8,size*8)
            c.fillStyle=Qt.rgba(.96,1,.66,.91*pulse)
            c.beginPath();c.arc(x,y,size*.73,0,Math.PI*2);c.fill()
        }
    }
}

import QtQuick

EffectCanvas {
    id: atmosphere
    objectName: "highAtmosphere"
    required property real clock
    required property bool motion
    required property color tint
    readonly property int step: motion ? Math.floor(clock*15) : 0
    onStepChanged: requestPaint()
    onTintChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx=beginPaint()
        ctx.clearRect(0,0,width,height)
        const radius=Math.max(1,width*.53)
        const glow=ctx.createRadialGradient(width*.16,height*.22,3,width*.16,height*.22,radius)
        glow.addColorStop(0,Qt.rgba(tint.r,tint.g,tint.b,.29))
        glow.addColorStop(.39,Qt.rgba(tint.r,tint.g,tint.b,.13))
        glow.addColorStop(1,"transparent")
        ctx.fillStyle=glow
        ctx.fillRect(0,0,width,height)
        for (let i=0;i<30;++i) {
            const x=(i*.618+.002*step)%1
            const y=((i*.373+1-Math.sin(step*.011+i)*.13)%1)*height
            ctx.fillStyle=Qt.rgba(tint.r,tint.g,tint.b,.14+(i%4)*.08)
            ctx.beginPath()
            ctx.arc(x*width,y,.6+i%4*.34,0,Math.PI*2)
            ctx.fill()
        }
    }
}

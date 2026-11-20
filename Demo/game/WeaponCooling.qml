import QtQuick

EffectCanvas {
    id: smoke
    required property point tip
    required property real clock
    required property real remaining
    required property bool motion
    property bool ultra:false
    textureLimit:ultra ? 1600 : 1000
    frameRate:ultra ? 34 : 22
    onTipChanged:requestPaint()
    onClockChanged:if (motion) requestPaint()
    onPaint: {
        const ctx=beginPaint()
        ctx.clearRect(0,0,width,height)
        const unit=Math.max(.4,height/720)
        const detail=ultra ? 16 : 7
        const cool=Math.min(1,remaining*1.8)
        for (let i=detail-1;i>=0;i--) {
            const age=((motion ? clock*.81 : .25)+(i+.5)/detail)%1
            const eddy=Math.sin(i*2.53+age*6.9)*age
            const x=tip.x+(eddy*21-age*13)*unit
            const y=tip.y-(age*age*65+age*32)*unit
            const radius=(3+age*32)*unit
            const opacity=Math.sin(Math.PI*age)*cool
            const vapour=ctx.createRadialGradient(x-radius*.17,y+radius*.16,0,x,y,radius)
            vapour.addColorStop(0,Qt.rgba(.81,.75,.77,opacity*(ultra ? .22 : .32)))
            vapour.addColorStop(.47,Qt.rgba(.62,.58,.63,opacity*.19))
            vapour.addColorStop(1,"transparent")
            ctx.fillStyle=vapour
            ctx.fillRect(x-radius,y-radius,radius*2,radius*2)
            if (ultra && age<.53 && motion && i%3===0) {
                ctx.fillStyle=Qt.rgba(1,.60,.29,cool*(1-age*1.8)*.65)
                ctx.fillRect(x,y,unit*1.7,unit*2.2)
            }
        }
    }
}

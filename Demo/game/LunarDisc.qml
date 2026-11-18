import QtQuick

Canvas {
    id:lunarDisc
    objectName:"starSkyMoon"
    required property bool redNight
    readonly property real diameter:Math.min(parent.width,parent.height)*.34
    x:parent.width*.68-width/2
    y:parent.height*.35-height/2
    width:diameter
    height:diameter
    onWidthChanged:requestPaint()
    onVisibleChanged:if (visible) requestPaint()
    onRedNightChanged:requestPaint()
    function noise(index) {
        const sample=Math.sin(index*73.467+12.653)*19139.491
        return sample-Math.floor(sample)
    }
    onPaint: {
        const ctx=getContext("2d"), centre=width*.5, r=width*.275, red=lunarDisc.redNight
        ctx.reset()
        const corona=ctx.createRadialGradient(centre,centre,r*.87,centre,centre,width*.495)
        corona.addColorStop(0,red ? "rgba(254,88,52,.70)" : "rgba(200,217,253,.67)")
        corona.addColorStop(.37,red ? "rgba(232,32,52,.34)" : "rgba(152,180,248,.29)")
        corona.addColorStop(1,"transparent")
        ctx.fillStyle=corona
        ctx.fillRect(0,0,width,height)
        ctx.translate(centre,centre)
        ctx.scale(r,r)
        ctx.beginPath()
        ctx.arc(0,0,1,0,Math.PI*2)
        const reflected=ctx.createRadialGradient(-.31,-.38,.04,0,0,1)
        reflected.addColorStop(0,red ? "#ffd0a0" : "#fffcda")
        reflected.addColorStop(.74,red ? "#e35142" : "#dbddda")
        reflected.addColorStop(1,red ? "#9d2c45" : "#959ebd")
        ctx.fillStyle=reflected
        ctx.fill()
        ctx.save()
        ctx.clip()
        for (let i=0;i<43;i++) {
            const angle=noise(i*3)*Math.PI*2
            const distance=Math.sqrt(noise(i*3+1))*.95
            const size=.025+noise(i*3+2)*.065
            ctx.fillStyle=red ? "rgba(112,15,34,.22)" : "rgba(49,65,101,.18)"
            ctx.beginPath()
            ctx.ellipse(Math.cos(angle)*distance-size,Math.sin(angle)*distance-size,size*2,size*1.47)
            ctx.fill()
        }
        ctx.restore()
    }
}

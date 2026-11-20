import QtQuick

Canvas {
    id:lock
    anchors.fill:parent
    property color tint:"#dcbfc8"
    onTintChanged:requestPaint()
    onVisibleChanged:if (visible) requestPaint()
    onPaint:{
        const c=getContext("2d")
        c.reset()
        c.clearRect(0,0,width,height)
        if (!visible || !width || !height) return
        c.save()
        c.scale(width/100,height/100)
        const span=Math.min(width,height)
        const links=Math.min(17,Math.max(6,Math.round(width/11)))
        for (const side of [-1,1]) {
            for (let i=0;i<links;++i) {
                const at=9+i*82/(links-1)
                c.save()
                c.translate(at,50+side*(at-50)*.62)
                c.rotate(side*.54+(i%2 ? .19 : -.12))
                c.lineWidth=span<32 ? 3.8 : 2.4
                c.strokeStyle="#4c3846"
                c.beginPath()
                c.ellipse(-5,-3.6,10,7.2)
                c.stroke()
                c.lineWidth*=.48
                c.strokeStyle=tint
                c.stroke()
                c.restore()
            }
        }
        const icon=Math.min(37,span*.67)
        c.restore()
        c.translate(width*.5,height*.52)
        c.scale(icon/36,icon/36)
        c.lineWidth=3.4
        c.strokeStyle=tint
        c.beginPath()
        c.moveTo(-8,0)
        c.lineTo(-8,-6)
        c.bezierCurveTo(-8,-19,8,-19,8,-6)
        c.lineTo(8,0)
        c.stroke()
        c.fillStyle="#30202c"
        c.fillRect(-13,-2,26,17)
        c.lineWidth=2
        c.strokeRect(-13,-2,26,17)
        c.fillStyle=tint
        c.beginPath()
        c.ellipse(-2,3,4,4)
        c.fill()
        c.fillRect(-1,6,2,4)
    }
}

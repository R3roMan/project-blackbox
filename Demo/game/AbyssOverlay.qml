import QtQuick

EffectCanvas {
    id: overlay
    textureLimit:1280
    frameRate:24
    objectName: "abyssOverlay"
    required property real clock
    required property bool motion
    required property bool hypnotised
    required property bool projected
    required property bool ink
    required property int blind
    required property real intensity
    required property point aim
    required property var grab
    visible: hypnotised || ink || blind > 0 || !!grab
    onVisibleChanged: if (visible) requestPaint()
    onClockChanged: if (visible && (hypnotised || grab)) requestPaint()
    onInkChanged:requestPaint()
    onBlindChanged:requestPaint()
    onIntensityChanged:requestPaint()
    onAimChanged: if (blind === 3) requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    function stain(ctx,x,y,r,seed) {
        ctx.fillStyle = "#e9080710"
        ctx.beginPath()
        for (let i=0; i<31; ++i) {
            const angle = i*Math.PI*2/31
            const edge = r*(.59+.28*Math.sin(seed+i*2.53)+i%4*.13)
            const px = x + Math.cos(angle)*edge
            const py = y + Math.sin(angle)*edge*.75
            if (i)
                ctx.lineTo(px,py)
            else
                ctx.moveTo(px,py)
        }
        ctx.closePath()
        ctx.fill()
        for (let i=0; i<17; ++i) {
            const angle = i*2.399+seed
            const radius = r*(.55+i*.049)
            ctx.beginPath()
            ctx.arc(x+Math.cos(angle)*radius,y+Math.sin(angle)*radius*.86,2+i%5*r*.027,0,2*Math.PI)
            ctx.fill()
        }
    }

    function limb(ctx, side, index, phase) {
        const root = side < 0 ? -width*.06 : width*1.06
        const y = height*(.75+index*.11)
        const curl = Math.sin(phase*7+index*.8)*width*.11
        const tip = width*.5+side*(width*.16+curl)
        const high = height*(.15+index*.18+.04*Math.sin(phase*9+index))
        ctx.beginPath()
        ctx.moveTo(root,y)
        ctx.bezierCurveTo(root-side*width*.39,y-height*.50,tip+side*width*.34,high-height*.21,tip,high)
        ctx.lineCap = "round"
        ctx.lineWidth = height*(.10-index*.018)
        ctx.strokeStyle = index%2 ? "#e32b1436" : "#f02e1c3b"
        ctx.stroke()
        ctx.lineWidth *= .37
        ctx.strokeStyle = "#586b396f"
        ctx.stroke()
        for (let i=0; i<5; ++i) {
            const s = i*.093
            ctx.fillStyle = "#86584872"
            ctx.beginPath()
            ctx.ellipse(tip+side*width*s*.55,high+height*s*s*.78,6+i*1.7,4+i*1.5)
            ctx.fill()
        }
    }

    onPaint: {
        const ctx = beginPaint()
        ctx.clearRect(0,0,width,height)
        const t = motion ? clock : 0
        if (blind) {
            const radius = blind === 3 ? height*.29 : Math.hypot(width,height)*(blind === 1 ? .54 : .48)
            const start = blind === 1 ? .71 : blind === 2 ? .43 : .42
            const x = blind === 3 ? aim.x : width*.5
            const y = blind === 3 ? aim.y : height*.5
            const dark = ctx.createRadialGradient(x,y,Math.max(1,radius*start),x,y,Math.max(2,radius))
            dark.addColorStop(0,"#0004070e")
            dark.addColorStop(.65,Qt.rgba(.014,.014,.025,Math.min(.88,intensity*(blind===3 ? 1 : .52))))
            dark.addColorStop(1,Qt.rgba(.009,.008,.017,blind===3 ? .99 : Math.min(.94,intensity*1.52)))
            ctx.fillStyle = dark
            ctx.fillRect(0,0,width,height)
        }
        if (hypnotised && projected) {
            ctx.lineWidth = height*.036
            for (let i=0; i<9; ++i) {
                ctx.beginPath()
                ctx.strokeStyle = ["#1fdd2878","#3e7835c6","#23403adb"][i%3]
                const base = height*(i/9+.03)
                for (let x=0; x<=width+20; x+=20) {
                    const y = base + height*.13*Math.sin(x/width*9+t*3+i*.66)
                    if (x)
                        ctx.lineTo(x,y)
                    else
                        ctx.moveTo(x,y)
                }
                ctx.stroke()
            }
        }
        if (ink) {
            const s = Math.min(width,height)
            stain(ctx,width*.10,height*.23,s*.146,14)
            stain(ctx,width*.87,height*.72,s*.156,44)
            stain(ctx,width*.57,height*.49,s*.106,150)
        }
        if (grab && grab.constrict) {
            for (const side of [-1,1])
                for (let i=0; i<3; ++i)
                    limb(ctx,side,i,t)
        } else if (grab) {
            ctx.lineWidth = 2
            for (let i=0; i<6; ++i) {
                const age = (grab.time*1.7+i*.163)%1
                const radius = 30+(1-age)*height*.58
                ctx.strokeStyle = Qt.rgba(.50,.94,1,(1-age)*.38)
                ctx.beginPath()
                ctx.ellipse(width*.51-radius,height*.55-radius*.58,radius*2,radius*1.16)
                ctx.stroke()
            }
        }
    }
}

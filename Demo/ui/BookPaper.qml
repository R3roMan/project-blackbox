import QtQuick

Canvas {
    id: paper
    property bool rightPage: false
    property int seed: 0

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onSeedChanged: requestPaint()

    function noise(i) {
        const v = Math.sin(i * 47.34 + seed * .113 + (rightPage ? 8.1 : 1.3)) * 14219.6
        return v - Math.floor(v)
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        if (width < 1 || height < 1) return
        ctx.scale(width / 320,height / 450)
        const base = ctx.createLinearGradient(0,0,320,0)
        base.addColorStop(0,rightPage ? "#ac906b" : "#c2a17a")
        base.addColorStop(.12,"#e8d6b5")
        base.addColorStop(.86,"#e6d1ac")
        base.addColorStop(1,rightPage ? "#c3a47b" : "#b49a76")
        ctx.fillStyle = base
        ctx.fillRect(0,0,320,450)
        for (let i=0; i<420; ++i) {
            ctx.fillStyle = i%3 ? "rgba(93,57,36,.085)" : "rgba(255,248,218,.18)"
            ctx.fillRect(320*noise(i),450*noise(i+451),.4+noise(i+923)*3.0,.55+noise(i+1183))
        }
        ctx.translate(rightPage ? 320 : 0,450)
        ctx.scale(rightPage ? -1 : 1,-1)
        // Jagged pooling at the edge, with diagonal streaks and small spatter.
        const wash = ctx.createRadialGradient(10,8,1,35,24,112)
        wash.addColorStop(0,"rgba(146,7,19,.88)")
        wash.addColorStop(.54,"rgba(177,27,36,.73)")
        wash.addColorStop(1,"rgba(154,29,42,.05)")
        ctx.fillStyle = wash
        ctx.beginPath()
        ctx.moveTo(0,0)
        ctx.lineTo(144,0)
        ctx.quadraticCurveTo(113,9,92,8)
        ctx.lineTo(112,16); ctx.lineTo(72,15)
        ctx.quadraticCurveTo(52,16,68,26)
        ctx.lineTo(87,46); ctx.lineTo(47,30)
        ctx.quadraticCurveTo(23,18,31,52)
        ctx.lineTo(39,83); ctx.lineTo(19,59); ctx.lineTo(18,102)
        ctx.quadraticCurveTo(9,74,0,94)
        ctx.closePath()
        ctx.fill()
        for (let i=0; i<29; ++i) {
            const x=noise(i+2091)*112, y=noise(i+2153)*103
            if (x+y > 142) continue
            const r=.55+noise(i+2181)*4.2
            ctx.fillStyle=i%3 ? "rgba(160,19,31,.53)" : "rgba(115,6,23,.68)"
            ctx.beginPath()
            ctx.moveTo(x-r,y-r*.7)
            ctx.quadraticCurveTo(x+r,y-r*1.3,x+r*.84,y)
            ctx.lineTo(x+r*2.1,y+r*1.35)
            ctx.quadraticCurveTo(x-r*.44,y+r*.62,x-r,y-r*.7)
            ctx.fill()
        }
        ctx.setTransform(1,0,0,1,0,0)
    }
}

import QtQuick

Canvas {
    id: emblem
    required property var item
    property color tint: "#e5ba8e"
    property bool onPaper: false
    onItemChanged:requestPaint()
    onTintChanged:requestPaint()
    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onPaint: {
        const ctx=getContext("2d")
        ctx.reset()
        const unit=Math.min(width,height)/100
        ctx.translate(width*.5,height*.5)
        ctx.scale(unit,unit)
        const ink=onPaper ? Qt.darker(tint,1.76) : tint
        ctx.lineJoin="round"
        ctx.lineCap="round"
        function line(points, fill) {
            ctx.beginPath()
            ctx.moveTo(points[0],points[1])
            for (let i=2;i<points.length;i+=2)
                ctx.lineTo(points[i],points[i+1])
            if (fill) {ctx.closePath();ctx.fill()}
            ctx.stroke()
        }
        function ring(x,y,r) {
            ctx.beginPath();ctx.arc(x,y,r,0,Math.PI*2);ctx.stroke()
        }
        ctx.strokeStyle=ink
        ctx.fillStyle=Qt.rgba(ink.r,ink.g,ink.b,.20)
        ctx.lineWidth=3.5
        line([-37,-27,-25,-38,25,-38,37,-27,37,27,25,38,-25,38,-37,27],true)
        switch (item.action) {
        case "power": case "power-upgrade":
            line([0,-24,19,0,0,24,-19,0],true)
            line([0,-15,11,0,0,15,-11,0],true)
            for (const side of [-1,1]) {line([side*20,0,side*31,0]);line([0,side*25,0,side*32])}
            break
        case "expand-shop": case "unlock": case "inventory":
            line([-23,17,-23,-15,22,-15,22,17],true)
            line([0,9,0,-8]);line([-9,0,9,0]);line([-24,24,24,24])
            break
        case "mystery": case "scramble":
            line([-21,-13,0,-25,21,-13,21,14,0,25,-21,14],true)
            line([-21,-13,0,-1,21,-13]);line([0,-1,0,25])
            for (const dot of [[-12,7],[10,8],[14,.5],[4,15]]) ring(dot[0],dot[1],1.8)
            break
        case "shop-quality":
            line([0,-24,6,-6,24,-6,10,5,15,24,0,12,-15,24,-10,5,-24,-6,-6,-6],true)
            break
        case "barrier-core": case "shield-upgrade":
            line([0,-24,21,-15,18,8,10,19,0,27,-10,19,-18,8,-21,-15],true)
            line([0,-13,10,-8,8,8,0,15,-8,8,-10,-8],true)
            break
        case "shop": case "shop-stat": case "repeat-upgrade":
            ring(0,0,22);ring(0,0,15);line([-5,-9,7,-9,7,0,-7,0,-7,9,7,9]);line([0,-14,0,14])
            break
        default:
            line([-22,-16,22,-16,23,18,-23,18],true)
            line([-12,-16,-12,-24,12,-24,12,-16])
            line([-11,1,11,1]);line([0,-9,0,11])
        }
    }
}

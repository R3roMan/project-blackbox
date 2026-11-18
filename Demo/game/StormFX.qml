import QtQuick

EffectCanvas {
    id:fx
    required property var strikes
    required property var charges
    required property var field
    required property real clock
    required property bool motion
    property bool castVisible: true
    textureLimit:1800
    frameRate:30
    visible:castVisible && !!field && (strikes.length>0 || charges.length>0)
    onClockChanged:if (visible) requestPaint()
    onStrikesChanged:if (visible) requestPaint()
    onChargesChanged:if (visible) requestPaint()

    function projected(marker) {return field.projection(marker.lane,marker.elevation,marker.depth)}

    function bolt(c,start,tip,seed,radius) {
        const joints=[]
        c.beginPath();c.moveTo(start.x,start.y)
        for (let i=1;i<=13;i++) {
            const f=i/13, sign=i%2 ? -1 : 1
            const x=start.x+(tip.x-start.x)*f+sign*Math.sin((seed+i)*14.6)*radius*Math.sin(f*Math.PI)
            const y=start.y+(tip.y-start.y)*f
            c.lineTo(x,y)
            joints.push([x,y])
        }
        c.stroke()
        return joints
    }

    onPaint: {
        const c=beginPaint()
        c.clearRect(0,0,width,height)
        for (const strike of strikes) {
            const spot=projected(strike)
            const source={x:spot.x+width*(.15-.30*((strike.seed*.727)%1)),y:-height*.07}
            const age=1-strike.life/strike.span
            c.globalAlpha=(1-age)*.8
            c.fillStyle="#68757cad"
            c.fillRect(0,0,width,height)
            c.lineJoin="round"
            c.strokeStyle="#887ade";c.lineWidth=16
            bolt(c,source,spot,strike.seed,width*.051)
            c.strokeStyle="#dbc5ff";c.lineWidth=7
            const joints=bolt(c,source,spot,strike.seed,width*.051)
            c.strokeStyle="#fff5ff";c.lineWidth=3
            bolt(c,source,spot,strike.seed,width*.051)
            for (let i=2;i<joints.length-3;i+=3) {
                const point={x:joints[i][0],y:joints[i][1]}
                c.lineWidth=1.8
                bolt(c,point,{x:point.x+(i%2 ? -.13 : .13)*width,y:point.y+height*.14},strike.seed+i,width*.014)
            }
        }
        for (const charge of charges) {
            const spot=projected(charge)
            const radius=Math.min(height*.20,Math.max(15,(charge.size || 1)*118*spot.scale))
            const turn=motion ? clock*4.8 : 0
            c.globalAlpha=(charge.visibility ?? 1)*.72
            c.strokeStyle="#d7bbff";c.lineWidth=Math.max(1.2,radius*.027)
            for (let thread=0;thread<3;thread++) {
                c.beginPath()
                for (let i=0;i<=12;i++) {
                    const a=turn+thread*2.094+i*.26
                    const r=radius*(1+Math.sin(i*6.7+turn)*.13)
                    const x=spot.x+Math.cos(a)*r,y=spot.y+Math.sin(a)*r*.72
                    if (i===0)c.moveTo(x,y);else c.lineTo(x,y)
                }
                c.stroke()
            }
        }
        c.globalAlpha=1
    }
}

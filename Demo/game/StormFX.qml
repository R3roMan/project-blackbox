import QtQuick

EffectCanvas {
    id:fx
    required property var strikes
    required property var charges
    required property var field
    required property real clock
    required property bool motion
    property bool castVisible: true
    property bool ultra:false
    textureLimit:1800
    frameRate:30
    visible:castVisible && !!field && (strikes.length>0 || charges.length>0)
    onClockChanged:if (visible) requestPaint()
    onStrikesChanged:if (visible) requestPaint()
    onChargesChanged:if (visible) requestPaint()
    onUltraChanged:if (visible) requestPaint()

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
            const joints=bolt(c,source,spot,strike.seed,width*.051)
            c.strokeStyle=ultra ? "#887e5aff" : "#887ade";c.lineWidth=ultra ? 24 : 16
            c.stroke()
            c.strokeStyle="#dbc5ff";c.lineWidth=7
            c.stroke()
            c.strokeStyle="#fff5ff";c.lineWidth=3
            c.stroke()
            for (let i=2;i<joints.length-3;i+=3) {
                const point={x:joints[i][0],y:joints[i][1]}
                c.lineWidth=1.8
                const branch=bolt(c,point,{x:point.x+(i%2 ? -.13 : .13)*width,y:point.y+height*.14},strike.seed+i,width*.014)
                c.strokeStyle="#fff5ff"
                c.stroke()
                if (ultra) {
                    const fork={x:branch[5][0],y:branch[5][1]}
                    bolt(c,fork,{x:fork.x+(i%2 ? -.064 : .064)*width,y:fork.y-height*.034},strike.seed+i*7,width*.010)
                    c.lineWidth=.9
                    c.strokeStyle="#afdfff"
                    c.stroke()
                }
            }
            if (ultra) {
                const radius=height*(.035+age*.105)
                const glow=c.createRadialGradient(spot.x,spot.y,0,spot.x,spot.y,radius)
                glow.addColorStop(0,"#fffaff")
                glow.addColorStop(.27,"#d8b7edff")
                glow.addColorStop(.57,"#7b786ef0")
                glow.addColorStop(1,"transparent")
                c.fillStyle=glow
                c.fillRect(spot.x-radius,spot.y-radius,radius*2,radius*2)
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

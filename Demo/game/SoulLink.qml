import QtQuick
import "Rules.js" as Rules

EffectCanvas {
    id: field
    required property var run
    required property int revision
    required property Item world
    required property string frontId
    required property bool active
    required property bool motion
    visible: {
        revision
        return active && !!world && (run.soulReturns.length > 0 || run.enemies.some(function(enemy) { return enemy.soulChannel }))
    }
    onVisibleChanged:if (visible) requestPaint()
    onRevisionChanged:if (visible) requestPaint()

    function source(lane, elevation, depth, front) {
        if (front === frontId) {
            const point = world.projection(lane,elevation,depth)
            return world.mapToItem(field,point.x,point.y)
        }
        const direction = Rules.directionToward(frontId,front)
        return {x:direction === "left" ? 0 : direction === "right" ? width : width*.5,
            y:direction === "up" ? 0 : direction === "down" ? height : height*.43}
    }
    function mote(ctx,x,y,r,alpha,returning) {
        const soul=ctx.createRadialGradient(x,y,0,x,y,Math.max(2,r*3))
        soul.addColorStop(0,Qt.rgba(.91,.97,1,alpha))
        soul.addColorStop(.22,Qt.rgba(returning ? .52 : .77,.77,1,alpha*.74))
        soul.addColorStop(1,"#0097dfff")
        ctx.fillStyle=soul
        ctx.fillRect(x-r*3,y-r*3,r*6,r*6)
        ctx.fillStyle=Qt.rgba(.95,.97,1,alpha)
        ctx.beginPath()
        ctx.ellipse(x-r*.24,y-r*.59,r*.48,r*1.18)
        ctx.fill()
    }
    onPaint: {
        const ctx=beginPaint()
        ctx.clearRect(0,0,width,height)
        if (!active || !world)
            return
        const time=motion ? run.time : .37
        for (const enemy of run.enemies) {
            if (!enemy.soulChannel)
                continue
            const finish=source(Rules.lanePosition(enemy),Rules.elevation(enemy)+60*Rules.enemySize(enemy),enemy.depth,enemy.front)
            for (let i=0; i<16; ++i) {
                const age=(time*.58+i*.117)%1
                const x=width*.5+(finish.x-width*.5)*age+Math.sin(age*5+i)*19*(1-age)
                const y=height*.88+(finish.y-height*.88)*age+Math.sin(age*Math.PI)*height*.08
                mote(ctx,x,y,2.1+(1-age)*5.8,Math.min(.78,Math.sin(age*Math.PI)*.89),false)
            }
        }
        for (const event of run.soulReturns) {
            const origin=source(event.lane,event.elevation,event.depth,event.front)
            const age=1-event.life/event.span
            for (let i=0; i<24; ++i) {
                const travel=Math.max(0,Math.min(1,(age-i*.012)*1.7))
                const x=origin.x+(width*.11-origin.x)*travel+Math.sin(i*2.4)*width*.13*Math.sin(Math.PI*travel)
                const y=origin.y+(height*.58-origin.y)*travel-Math.sin(Math.PI*travel)*(29+i%6*17)
                mote(ctx,x,y,3+i%4,Math.min(1,travel*7)*(1-travel)*.94,true)
            }
        }
    }
}

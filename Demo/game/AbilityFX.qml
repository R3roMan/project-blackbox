import QtQuick
import "Conditions.js" as Weather

EffectCanvas {
    id:fx
    required property var effects
    required property real clock
    required property string frontId
    property var world:null
    property bool active:true
    property bool motion:true
    property bool threeDimensional:false
    property real obscurity:0
    property real spray:0
    textureLimit:3840
    frameRate:30
    visible:active && (spray>0 || effects.some(function(e){return e.front===frontId}))
    onClockChanged:if (visible) requestPaint()
    onEffectsChanged:if (visible) requestPaint()
    onSprayChanged:if (visible) requestPaint()

    function line(ctx,points,fill) {
        ctx.beginPath();ctx.moveTo(points[0],points[1])
        for (let i=2;i<points.length;i+=2) ctx.lineTo(points[i],points[i+1])
        if (fill) {ctx.closePath();ctx.fill()}
        else ctx.stroke()
    }

    function arc(ctx,r,phase,span) {
        ctx.beginPath();ctx.arc(0,0,r,phase,phase+span);ctx.stroke()
    }

    function center(effect,point) {
        if (world && point)
            return world.projection(point.lane,point.elevation,point.depth)
        return {x:effect.x*width,y:effect.y*height,scale:height*.0011}
    }

    function drawEffect(c,e,r,p,detail) {
        const spokes=4+e.power*2
        if (e.motif==="mark" || e.kind==="critical" || e.kind==="stun") {
            arc(c,r*.84,-Math.PI/2,p*3+Math.PI)
            arc(c,r*.45,p*3,Math.PI*1.6)
            for (let i=0;i<4;i++) {
                c.save();c.rotate(i*Math.PI*.5)
                line(c,[r*.56,0,r*.95,0]);c.restore()
            }
            if(e.kind==="stun") for(let i=0;i<3;i++) {
                c.save();c.rotate(p*4+i*2.094);c.translate(r*.7,0)
                line(c,[-4,0,0,-7,4,0,0,7],true);c.restore()
            }
            return
        }
        if (e.kind==="electric" || e.kind==="intercept") {
            for (let i=0;i<spokes;i++) {
                const direction=i*Math.PI*2/spokes+p*.47
                c.save();c.rotate(direction)
                const points=[0,0]
                for (let j=1;j<=7;j++) points.push(r*j/7,Math.sin(j*8+i+p*13)*r*.12)
                line(c,points)
                c.lineWidth*=.52
                line(c,[r*.49,points[7],r*.72,-r*.19,r*.92,-r*.12])
                c.restore()
            }
            return
        }
        if (e.kind==="burn") {
            for(let i=0;i<spokes;i++) {
                const a=i*2.3999, x=Math.cos(a)*r*.78,y=Math.sin(a)*r*.29
                c.beginPath();c.moveTo(x-r*.095,y);c.quadraticCurveTo(x-r*.22,y-r*.39,x+Math.sin(i+p*9)*r*.19,y-r*.84)
                c.quadraticCurveTo(x+r*.28,y-r*.30,x+r*.12,y);c.fill()
            }
            return
        }
        if (e.kind==="freeze") {
            for(let i=0;i<spokes;i++) {
                c.save();c.rotate(i*2.39996+p*.38)
                line(c,[r*.32,0,r*.57,-r*.102,r*.98,0,r*.57,r*.102],i%3===0)
                c.restore()
            }
            arc(c,r*.72,p*.46,Math.PI*2)
            return
        }
        if (e.motif==="shield" || e.kind==="heal") {
            if(e.kind==="guard") {
                line(c,[-r*.64,-r*.59,r*.64,-r*.59,r*.61,r*.28,0,r*.73,-r*.61,r*.28,-r*.64,-r*.59])
                line(c,[-r*.51,-r*.46,r*.51,-r*.46])
                arc(c,r*.93,p,Math.PI)
            } else {
                for (let i=0;i<4;i++) {
                    c.save();c.rotate(i*Math.PI*.5);c.translate(r*(.21+p*.30),0)
                    line(c,[-r*.13,0,r*.13,0]);line(c,[0,-r*.13,0,r*.13]);c.restore()
                }
            }
            return
        }
        if(e.kind==="reload" || e.kind==="coin") {
            for (let i=0;i<3+e.power;i++) {
                const a=i*2.3999+p
                c.save();c.translate(Math.cos(a)*r*.52,Math.sin(a)*r*.38-r*p*.28);c.rotate(-.42+p*.65)
                if(e.kind==="coin") {
                    c.beginPath();c.ellipse(-r*.105,-r*.105,r*.21,r*.21);c.stroke()
                    line(c,[0,-r*.07,0,r*.07])
                } else {
                    line(c,[-r*.063,r*.13,-r*.063,-r*.06,0,-r*.127,r*.063,-r*.06,r*.063,r*.13],true)
                }
                c.restore()
            }
            return
        }
        if (e.kind==="cut" || e.kind==="wind" || e.kind==="knockback") {
            for (let i=0;i<3;i++) {
                c.save();c.scale(1,e.kind==="cut" ? .78 : .42)
                const start=-1.5+p*2.5+i*.23
                arc(c,r*(1-i*.17),start,e.kind==="cut" ? 1.63 : 2.9)
                c.restore()
            }
            return
        }
        if (e.kind==="blood" || e.kind==="poison" || e.kind==="sticky") {
            for(let i=0;i<spokes;i++) {
                const a=i*2.39996+p*.92
                const size=r*(.048+i%3*.018)
                c.save();c.translate(Math.cos(a)*r*.72,Math.sin(a)*r*.46-(e.kind==="blood" ? .21-p*.25 : 0)*r)
                c.beginPath()
                if(e.kind==="poison"){c.arc(0,0,size,0,2*Math.PI);c.stroke()}
                else {c.ellipse(-size/2,-size,size,size*2.43);c.fill()}
                c.restore()
            }
            return
        }
        const portal=["rune","void","weaken","blind","summon"].includes(e.kind)
        if (portal) {
            arc(c,r*.79,p,Math.PI*2)
            arc(c,r*.62,-p,Math.PI*1.54)
            c.save();c.rotate(p*.85)
            const marks=[]
            for(let i=0;i<=5;i++) {const a=i*Math.PI*.8-Math.PI*.5;marks.push(Math.cos(a)*r*.60,Math.sin(a)*r*.60)}
            line(c,marks);c.restore()
        } else {
            for(let i=0;i<Math.min(e.power+1,4);i++)
                arc(c,r*(1-i*.19),p,Math.PI*2)
            if(detail) for(let i=0;i<spokes;i++) {
                c.save();c.rotate(i*2.39996+p);line(c,[r*.76,0,r*1.16,0]);c.restore()
            }
        }
    }

    onPaint: {
        const c=beginPaint(),w=width,h=height
        c.clearRect(0,0,w,h)
        if (spray>0) {
            c.fillStyle=Qt.rgba(.72,.60,.04,spray*.12);c.fillRect(0,0,w,h)
            for (let i=0;i<13;i++) {
                c.beginPath();c.ellipse(((i*.618)%1)*w,((i*.397+.13)%1)*h,18+i%4*11,30+i%3*18)
                c.fillStyle=Qt.rgba(.78,.67,.04,spray*.23);c.fill()
            }
        }
        for (const e of effects) {
            if (e.front!==frontId) continue
            const t=Math.max(0,Math.min(1,1-e.life/e.span)),p=motion ? t : .39
            const alpha=Math.min(1,(1-t)*1.7),points=e.points?.length ? e.points : [null]
            for (const point of points) {
                const pos=center(e,point)
                const base=point ? Math.min(h*.16,Math.max(22,pos.scale*81)) : h*(e.anchor==="field" ? .23 : .135)
                const radius=base*(.66+p*.58)+(e.power-1)*4
                c.save();c.translate(pos.x,pos.y)
                const atmosphere=1-obscurity*(1-Weather.fogVisibility(point?.depth || 320))*.73
                c.globalAlpha=alpha*atmosphere*(threeDimensional ? .57 : .91)
                c.strokeStyle=e.color;c.fillStyle=e.color
                c.lineWidth=1.5+e.power*.44;c.lineCap="round";c.lineJoin="round"
                drawEffect(c,e,radius,p,!threeDimensional)
                c.restore()
            }

        }
    }
}

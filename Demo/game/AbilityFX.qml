import QtQuick

EffectCanvas {
    id:fx
    required property var effects
    required property real clock
    required property string frontId
    property bool active:true
    property bool motion:true
    property real spray:0
    textureLimit:1400
    frameRate:30
    visible:active && (spray>0 || effects.some(function(e){return e.front===frontId}))
    onClockChanged:if (visible) requestPaint()
    onEffectsChanged:if (visible) requestPaint()
    onSprayChanged:if (visible) requestPaint()
    onPaint: {
        const c=beginPaint(),w=width,h=height
        if (spray>0) {
            c.fillStyle=Qt.rgba(.72,.60,.04,spray*.12);c.fillRect(0,0,w,h)
            for (let i=0;i<13;i++) {
                c.beginPath();c.ellipse(((i*.618)%1)*w,((i*.397+.13)%1)*h,18+i%4*11,30+i%3*18)
                c.fillStyle=Qt.rgba(.78,.67,.04,spray*.23);c.fill()
            }
        }
        for (const e of effects) {
            if (e.front!==frontId) continue
            const t=1-e.life/e.span,p=motion ? t : .4,x=e.x*w,y=e.y*h,r=(.10+p*.45)*Math.min(w,h)
            c.save();c.translate(x,y);c.globalAlpha=Math.min(1,(1-t)*1.5);c.strokeStyle=e.color;c.fillStyle=e.color
            c.lineWidth=1.5+e.power*.65;c.shadowColor=e.color;c.shadowBlur=9+e.power*3
            const spokes=6+e.power*3
            if (e.kind==="electric") {
                for (let i=0;i<spokes;i++) {
                    const a=i*Math.PI*2/spokes+p*.3;c.beginPath();c.moveTo(0,0)
                    for (let j=1;j<=7;j++) {const angle=a+Math.sin(j*8+i+clock*25)*.20;c.lineTo(Math.cos(angle)*r*j/7,Math.sin(angle)*r*j/7)}
                    c.stroke()
                }
            } else if (e.kind==="burn") {
                for (let i=0;i<spokes;i++) {
                    const a=i*2.3999,px=Math.cos(a)*r*.8,py=Math.sin(a)*r*.38
                    c.beginPath();c.moveTo(px-8,py);c.quadraticCurveTo(px-20,py-35,px+Math.sin(i+p*15)*11,py-65-p*50);c.quadraticCurveTo(px+24,py-25,px+8,py);c.fill()
                }
            } else if (e.kind==="freeze") {
                for (let i=0;i<spokes;i++) {
                    const a=i*Math.PI*2/spokes;c.save();c.rotate(a);c.beginPath();c.moveTo(r*.25,0);c.lineTo(r,0);c.moveTo(r*.65,-12);c.lineTo(r*.78,0);c.lineTo(r*.65,12);c.stroke();c.restore()
                }
                c.beginPath();c.arc(0,0,r,0,Math.PI*2);c.stroke()
            } else if (e.kind==="guard" || e.kind==="heal") {
                c.beginPath()
                if (e.kind==="guard") {c.moveTo(-r*.45,-r*.45);c.lineTo(r*.45,-r*.45);c.quadraticCurveTo(r*.50,r*.25,0,r*.55);c.quadraticCurveTo(-r*.50,r*.25,-r*.45,-r*.45)}
                else {c.moveTo(-r*.5,0);c.lineTo(r*.5,0);c.moveTo(0,-r*.5);c.lineTo(0,r*.5)}
                c.stroke()
            } else {
                for (let ring=0;ring<e.power;ring++) {
                    c.beginPath();c.ellipse(-r*(1-ring*.12),-r*(e.kind==="wind" ? .36 : 1)*(1-ring*.12),2*r*(1-ring*.12),2*r*(e.kind==="wind" ? .36 : 1)*(1-ring*.12));c.stroke()
                }
                for (let i=0;i<spokes;i++) {
                    const a=i*Math.PI*2/spokes+(e.kind==="void" ? -p*3 : p)
                    c.save();c.rotate(a);c.translate(r*.7,0)
                    if (e.kind==="poison") {c.beginPath();c.arc(0,Math.sin(clock*5+i)*8,5+i%3*3,0,Math.PI*2);c.stroke()}
                    else {c.fillRect(0,0,e.kind==="explosive" ? r*.3 : 8,3+e.power)}
                    c.restore()
                }
            }
            c.restore()
        }
    }
}

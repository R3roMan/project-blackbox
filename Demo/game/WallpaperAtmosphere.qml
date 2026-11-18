import QtQuick

EffectCanvas {
    id: atmosphere
    required property string front
    required property real clock
    required property real night
    required property bool motion
    required property int detail
    readonly property int beat: motion ? Math.floor(clock*16) : 0
    textureLimit:960
    frameRate:16
    onBeatChanged:requestPaint()
    onNightChanged:requestPaint()
    onFrontChanged:requestPaint()
    onDetailChanged:requestPaint()
    onPaint: {
        const c=beginPaint()
        if (!c) return
        c.clearRect(0,0,width,height)
        const time=beat/16
        if (front==="up") {
            const count=[52,94,156][detail] || 94
            for (let i=0;i<count;i++) {
                const x=width*((i*.61803399+.34)%1)
                const y=height*((i*.41421356+.14)%1)
                const blink=Math.pow(.5+.5*Math.sin(time*(.71+i%8*.19)+i*2.39996),3)
                const size=.55+i%5*.22+blink*.67
                c.fillStyle=i%9===0 ? "#ffe9c7" : i%4===0 ? "#b3cdfd" : "#e1e5ff"
                c.globalAlpha=(.15+blink*.59)*(.48+night*.52)
                c.fillRect(x,y,size,size)
                if (i%12===0 && blink>.32) {
                    c.globalAlpha*=.60
                    c.fillRect(x-size*1.15,y+size*.33,size*3.3,Math.max(.65,size*.23))
                    c.fillRect(x+size*.34,y-size*1.07,Math.max(.65,size*.24),size*3.12)
                }
            }
        } else if (front==="down") {
            const count=[27,51,82][detail] || 51
            for (let i=0;i<count;i++) {
                const age=((i*.61803399+time*(.034+i%4*.013))%1)
                const drift=Math.sin(time*.45+i)*.021
                const x=width*((i*.381966+.17+age*.16+drift)%1)
                const y=height*((i*.414214+.3+(1-age)*.61)%1)
                const size=(1+i%5*.55)*(1+age*.89)
                const life=Math.sin(age*Math.PI)
                c.fillStyle=i%4===0 ? "#493458" : "#100918"
                c.globalAlpha=life*(i%4===0 ? .70 : .83)
                c.beginPath()
                c.ellipse(x,y,size,size*(1.5+age*.5));c.fill()
            }
            if (detail>0) {
                for (let i=0;i<3;i++) {
                    const x=width*((.21+i*.31+Math.sin(time*.22+i)*.057))
                    const y=height*(.62+i*.08+Math.cos(time*.29+i)*.052)
                    const radius=Math.max(1,width*(.13+.024*i))
                    const haze=c.createRadialGradient(x,y,1,x,y,radius)
                    haze.addColorStop(0,i%2 ? "#7f291b3a" : "#95100820")
                    haze.addColorStop(1,"transparent")
                    c.globalAlpha=.54
                    c.fillStyle=haze
                    c.fillRect(x-radius,y-radius,radius*2,radius*2)
                }
            }
        }
        c.globalAlpha=1
    }
}

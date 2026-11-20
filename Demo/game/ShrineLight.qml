import QtQuick
import "Conditions.js" as Conditions
import "Scenery.js" as Scenery

EffectCanvas {
    id:light
    required property string front
    required property string phase
    required property string weather
    required property real clock
    required property real solarTime
    property bool motion:true
    property bool windy:false
    property bool cloudy:false
    property int detail:1
    readonly property bool night:Conditions.isNight(phase)
    readonly property bool lanterns:front==="front"
    readonly property bool shafts:detail===3 && !night && (cloudy || ["sunrise","sunset"].includes(phase))
        && !Conditions.isRain(weather) && weather!=="winter"
    frameRate:detail===3 ? 24 : 12
    readonly property int beat:motion ? Math.floor(clock*frameRate) : 0
    textureLimit:detail===3 ? 1560 : 850
    onBeatChanged:requestPaint()
    onPhaseChanged:requestPaint()
    onWeatherChanged:requestPaint()
    onShaftsChanged:requestPaint()
    onDetailChanged:requestPaint()
    function halo(c,x,y,r,sx,sy,strength,color) {
        c.save()
        c.translate(x,y)
        c.scale(sx,sy)
        const glow=c.createRadialGradient(0,0,0,0,0,r)
        glow.addColorStop(0,Qt.rgba(color[0],color[1],color[2],strength))
        glow.addColorStop(.28,Qt.rgba(color[0],color[1]*.92,color[2]*.83,strength*.58))
        glow.addColorStop(.67,Qt.rgba(color[0],color[1]*.76,color[2]*.53,strength*.15))
        glow.addColorStop(1,"transparent")
        c.fillStyle=glow
        c.fillRect(-r,-r,r*2,r*2)
        c.restore()
    }
    function glowLanterns(c,t) {
        const fog=weather==="fog" || Conditions.isRain(weather)
        const sources=[[190,284,25],[575,283,25],[289,275,11],[478,274,11],[358,272,8],[412,272,8]]
        for (let i=0;i<sources.length;i++) {
            const [x,y,radius]=sources[i]
            const flicker=.78+.13*Math.sin(t*5.77+i*3.8)+.061*Math.sin(t*12.3+i*1.7)
                +.035*Math.sin(t*17.55+i*2)
            const strength=flicker*(night ? 1 : phase==="daytime" ? .49 : .78)
            halo(c,x+1,y+radius*.61,radius*.96,1.33,.33,strength*.27,[1,.64,.30])
            if (fog) {
                const drift=Math.sin(t*(windy ? 1.17 : .38)+i)*radius*.23
                halo(c,x+drift,y-radius*.03,radius*1.62,1.06,.59,strength*.22,[1,.75,.43])
                if (detail===3) halo(c,x-drift*.6,y+3,radius*1.29,1.19,.29,strength*.18,[1,.70,.43])
            }
            halo(c,x,y,radius,1,.83,strength*.56,[1,.71,.37])
            halo(c,x,y,radius*.32,1,.94,strength*.79,[1,.91,.67])
        }
    }
    function sunShafts(c,t) {
        const sky=Conditions.sky(phase,solarTime,front)
        const low=phase!=="daytime"
        const color=phase==="sunset" ? [1,.69,.46] : phase==="sunrise" ? [1,.87,.62] : [.98,.96,.81]
        const sx=front==="left" ? sky.sunX*768 : (phase==="sunset" ? .24 : .11)*768
        const sy=front==="left" ? sky.sunY*432 : (low ? .33 : .15)*432
        const displacement=Scenery.cloudOffset(t,windy)*.011
        for (let i=0;i<6;i++) {
            const shift=Math.sin(displacement+i*.72)*.14
            const angle=1.43 + shift + (i-2.9)*.19
            const length=205+i%3*38
            const strength=(.025+.052*Math.pow(.5+.5*Math.sin(displacement+i*3.7),1.45))*(low ? 1.2 : .72)
            c.save();c.translate(sx,sy);c.rotate(angle)
            const gradient=c.createLinearGradient(0,0,length,0)
            gradient.addColorStop(0,"transparent")
            gradient.addColorStop(.17,Qt.rgba(color[0],color[1],color[2],strength*.55))
            gradient.addColorStop(.42,Qt.rgba(color[0],color[1],color[2],strength))
            gradient.addColorStop(1,"transparent")
            c.fillStyle=gradient
            for (let band=1;band<=4;band++) {
                const spread=(i%2 ? 16 : 24)*band/4
                c.beginPath();c.moveTo(0,0);c.lineTo(length,-spread);c.lineTo(length,spread);c.closePath();c.fill()
            }
            c.restore()
        }
    }
    onPaint: {
        const c=beginPaint()
        c.clearRect(0,0,width,height)
        c.scale(width/768,height/432)
        const t=motion ? clock : 0
        if (shafts) sunShafts(c,t)
        if (lanterns) glowLanterns(c,t)
    }
}

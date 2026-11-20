import QtQuick
import "Conditions.js" as Conditions
import "Scenery.js" as Scenery

EffectCanvas {
    id:layer
    property string front:"left"
    property string phase:"daytime"
    property string weather:"clear"
    property bool cloudy:false
    property bool cloudsOnly:false
    property bool windy:false
    property bool motion:true
    property real clock:0
    property real solarTime:clock
    readonly property bool window:front==="right"
    readonly property bool overhead:front==="up"
    readonly property bool distant:!cloudsOnly && (front==="left" || front==="front" || window || overhead)
    readonly property url cloudTexture:Qt.resolvedUrl("../assets/landscape/cloudbank.webp")
    readonly property url skylineMatte:Qt.resolvedUrl("../assets/landscape/"+(front==="front" ? "shrine-sky" : "approach-sky")+".png")
    readonly property int beat:motion ? Math.floor(clock*(cloudy || overhead ? 8 : 1)) : 0
    textureLimit:1152
    frameRate:8
    onBeatChanged:requestPaint()
    onWeatherChanged:requestPaint()
    onPhaseChanged:requestPaint()
    onSolarTimeChanged:if (!motion) requestPaint()
    onCloudyChanged:requestPaint()
    onWindyChanged:requestPaint()
    onFrontChanged:requestPaint()
    onPaint: {
        const c=beginPaint()
        c.clearRect(0,0,width,height)
        const matte=!cloudsOnly && (front==="left" || front==="front")
        if (!width || !height || (matte && !imageReady(skylineMatte))) return
        const sky=Conditions.sky(phase,solarTime,"left")
        const night=Conditions.isNight(phase), red=phase==="bloodMoon"
        const dawn=phase==="sunrise", dusk=phase==="sunset"
        const thinClouds=overhead && !cloudsOnly && !night
        const cloudsReady=(cloudy || thinClouds) && imageReady(cloudTexture)
        const time=motion ? clock : 0
        c.save()
        c.scale(width/768,height/432)
        if (window) {
            // Two visible panes end at the outdoor ridgeline. Leave the frame,
            // drain pipe, mullion and distant mountains in front of the sky.
            c.beginPath()
            c.moveTo(38,99);c.lineTo(58,107);c.lineTo(55,163);c.lineTo(37,173);c.closePath()
            c.moveTo(68,109);c.lineTo(205,149);c.lineTo(206,155);c.lineTo(181,169)
            c.lineTo(164,171);c.lineTo(135,161);c.lineTo(117,165);c.lineTo(95,172);c.lineTo(68,169);c.closePath()
            c.clip()
            c.translate(32,98);c.scale(.242,.38)
        }
        if (distant) {
            const skyDepth=overhead ? 432 : 210
            const paint=c.createLinearGradient(0,0,0,skyDepth)
            const colors=Scenery.skyColors(phase,weather)
            if (overhead) {
                paint.addColorStop(0,colors[0])
                paint.addColorStop(1,colors[1])
            } else {
                paint.addColorStop(0,colors[1]);paint.addColorStop(.69,colors[2]);paint.addColorStop(1,colors[3])
            }
            c.fillStyle=paint;c.fillRect(0,0,768,overhead ? 432 : 300)
            if (overhead && !night) {
                const scatter=c.createRadialGradient(473,192,20,473,192,230)
                scatter.addColorStop(0,dusk ? "#37f49a7d" : dawn ? "#46fbd5b3" : "#3872badc")
                scatter.addColorStop(1,"transparent")
                c.fillStyle=scatter;c.fillRect(0,0,768,432)
            }
            if (night) {
                for (let i=0;i<(overhead ? 148 : 67);i++) {
                    const y=(i*89)%(overhead ? 428 : 175)
                    const intensity=(.21+(i%4)*.105)*(overhead ? .83 : 1-y/215)
                    c.fillStyle=red ? Qt.rgba(1,.79,.73,intensity) : Qt.rgba(.84,.88,1,intensity)
                    c.fillRect((i*477)%761,y,1+(i%7===0 ? .6 : 0),1)
                }
            } else if (front==="left" || window) {
                const x=sky.sunX*768, y=sky.sunY*432
                const radius=dawn || dusk ? 6 : 5
                const halo=c.createRadialGradient(x,y,radius*.8,x,y,radius*5.3)
                halo.addColorStop(0,dusk ? "#fafdb05a" : "#f9fff3c1")
                halo.addColorStop(.25,dusk ? "#a6ff984f" : "#96ffe5a0")
                halo.addColorStop(1,"transparent")
                c.fillStyle=halo;c.fillRect(x-70,y-70,140,140)
                c.fillStyle=dusk ? "#ffd592" : "#fff6ce"
                c.beginPath();c.arc(x,y,radius,0,Math.PI*2);c.fill()
            }
        }
        if (cloudsReady) {
            const skyHeight=overhead ? 290 : 110
            const rain=Conditions.isRain(weather)
            const opacity=(cloudy ? (rain ? .87 : .68) : .27)*(night ? .48 : 1)
            const drift=Scenery.cloudOffset(time,windy)+(front==="front" ? 490 : overhead ? 295 : 0)
            // Oversized banks keep both texture edges outside the viewport.
            // Each bank fades completely before its horizontal position wraps.
            for (let bank=0;bank<2;++bank) {
                const cycle=(drift/820+bank*.5)%1
                c.globalAlpha=opacity*Math.pow(Math.sin(cycle*Math.PI),2)
                const x=-642+cycle*470
                const y=(overhead ? 61 : -skyHeight*.48)+bank*skyHeight*.09
                c.drawImage(cloudTexture,x,y,1500,skyHeight*1.12)
            }
            c.globalAlpha=1
            if (rain || night) {
                const veil=c.createLinearGradient(0,0,0,skyHeight)
                veil.addColorStop(0,night ? "#a3071326" : "#a535475b")
                veil.addColorStop(1,"transparent")
                c.fillStyle=veil;c.fillRect(0,0,768,skyHeight)
            }
        }
        c.restore()
        if (matte) {
            c.globalCompositeOperation="destination-in"
            c.drawImage(skylineMatte,0,0,width,height)
            c.globalCompositeOperation="source-over"
        }
    }
}

import QtQuick

Item {
    id: weatherFx
    objectName: "weatherEffects"
    required property string condition
    required property real time
    required property bool motion
    property bool starSky:false
    readonly property bool redNight:condition==="bloodMoon"
    readonly property bool moonVisible:starSky && ["night","bloodMoon","incursion"].includes(condition)

    property real gust: 0

    Rectangle {
        anchors.fill: parent
        visible: ["night","bloodMoon","rain","inferno","winter","incursion"].includes(weatherFx.condition)
        gradient: Gradient {
            GradientStop { position: 0; color: weatherFx.redNight ? "#ac731027" : weatherFx.condition === "inferno" ? "#75381821" : weatherFx.condition === "incursion" ? "#bb130a22" : weatherFx.condition === "night" ? "#ba0a193d" : "#54435a71" }
            GradientStop { position: .50; color: weatherFx.redNight ? "#82501225" : weatherFx.condition === "inferno" ? "#30b64027" : weatherFx.condition === "incursion" ? "#8722143b" : weatherFx.condition === "night" ? "#74071138" : "#41353b59" }
            GradientStop { position: 1; color: weatherFx.redNight ? "#9b2a0b1a" : weatherFx.condition === "inferno" ? "#a5d64614" : weatherFx.condition === "winter" ? "#77739cc5" : weatherFx.condition === "night" ? "#6a101a30" : "#46324958" }
        }
    }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height * .56
        visible: weatherFx.condition === "night"
        opacity: weatherFx.motion ? .42 + Math.sin(weatherFx.time * .48) * .09 : .42
        gradient: Gradient {
            GradientStop { position: 0; color: "#426279c3" }
            GradientStop { position: 1; color: "transparent" }
        }
    }
    Canvas {
        id:lunarDisc
        objectName:"starSkyMoon"
        readonly property real diameter:Math.min(weatherFx.width,weatherFx.height)*.44
        x:weatherFx.width*.68-width/2
        y:weatherFx.height*.35-height/2
        width:diameter
        height:diameter
        visible:weatherFx.moonVisible
        onWidthChanged:requestPaint()
        onVisibleChanged:if (visible) requestPaint()
        Connections {
            target:weatherFx
            function onRedNightChanged() { lunarDisc.requestPaint() }
        }
        onPaint: {
            const ctx=getContext("2d"), centre=width*.5, r=width*.275, red=weatherFx.redNight
            ctx.reset()
            const corona=ctx.createRadialGradient(centre,centre,r*.87,centre,centre,width*.495)
            corona.addColorStop(0,red ? "rgba(254,88,52,.70)" : "rgba(200,217,253,.67)")
            corona.addColorStop(.37,red ? "rgba(232,32,52,.34)" : "rgba(152,180,248,.29)")
            corona.addColorStop(1,"transparent")
            ctx.fillStyle=corona
            ctx.fillRect(0,0,width,height)
            ctx.translate(centre,centre)
            ctx.scale(r,r)
            ctx.beginPath()
            ctx.arc(0,0,1,0,Math.PI*2)
            const reflected=ctx.createRadialGradient(-.31,-.38,.04,0,0,1)
            reflected.addColorStop(0,red ? "#ffd0a0" : "#fffcda")
            reflected.addColorStop(.74,red ? "#e35142" : "#dbddda")
            reflected.addColorStop(1,red ? "#9d2c45" : "#959ebd")
            ctx.fillStyle=reflected
            ctx.fill()
            ctx.save()
            ctx.clip()
            for (let i=0;i<43;i++) {
                const angle=i*2.39996
                const distance=((i*.38197)%1)*.94
                const size=.028+(i%4)*.019
                ctx.fillStyle=red ? "rgba(112,15,34,.22)" : "rgba(49,65,101,.18)"
                ctx.beginPath()
                ctx.ellipse(Math.cos(angle)*distance-size,Math.sin(angle)*distance-size,size*2,size*1.47)
                ctx.fill()
            }
            ctx.restore()
        }
    }
    EffectCanvas {
        id: rain
        anchors.fill: parent
        visible: ["rain","meteor","inferno","winter","incursion","windy","glitch"].includes(weatherFx.condition)
        onVisibleChanged: if (visible) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: weatherFx
            function onTimeChanged() { if (rain.visible && weatherFx.motion) rain.requestPaint() }
            function onConditionChanged() { if (rain.visible) rain.requestPaint() }
            function onGustChanged() { if (rain.visible) rain.requestPaint() }
        }
        onPaint: {
            const ctx = beginPaint()
            ctx.clearRect(0, 0, width, height)
            const time = weatherFx.motion ? weatherFx.time : 0
            if (weatherFx.condition === "windy") {
                const gust = weatherFx.gust / 1.26
                ctx.lineCap = "round"
                for (let i=0; i<62; ++i) {
                    const speed = .24+i%7*.028
                    const x = ((i*.618+time*speed)%1.35-.17)*width
                    const y = (i*.1838%1)*height + Math.sin(time*4+i)*18
                    const tail = (17+i%7*12)*(1+gust*3)
                    ctx.beginPath()
                    ctx.moveTo(x-tail,y+tail*.14)
                    ctx.quadraticCurveTo(x-tail*.38,y-tail*.14,x,y)
                    ctx.strokeStyle = Qt.rgba(.74,.94,.89,.07+gust*.48+i%3*.027)
                    ctx.lineWidth = 1+i%3*(1+gust*3)
                    ctx.stroke()
                }
                if (gust > 0) {
                    const plume = ctx.createLinearGradient(0,0,width,0)
                    plume.addColorStop(0,"#00b5fff3")
                    plume.addColorStop(.45,Qt.rgba(.69,.95,.89,Math.sin(gust*Math.PI)*.27))
                    plume.addColorStop(1,"#00b5fff3")
                    ctx.fillStyle = plume
                    ctx.fillRect(0,0,width,height)
                }
                return
            }
            if (weatherFx.condition === "glitch") {
                const beat = Math.floor(time*9)
                for (let i=0; i<22; ++i) {
                    const y = (i*.3911+beat*.013)%1
                    const x = (i*.621+beat*.019)%1
                    if (y > .13 && y < .85 && i%4 !== 0)
                        continue
                    ctx.fillStyle = ["#4be946a1","#384adaf2","#596b54f2"][i%3]
                    ctx.fillRect(x*width-width*.22,y*height,width*(.18+i%5*.11),1+i%5)
                }
                return
            }
            if (weatherFx.condition === "winter") {
                for (let i=0;i<104;++i) {
                    const x = ((i*.3819+time*.018+i%4*.001*time)%1)*width+Math.sin(time+i)*19
                    const y = ((i*.6128+time*(.032+i%5*.011))%1)*height
                    ctx.beginPath()
                    ctx.fillStyle = Qt.rgba(.73+i%3*.087,.88,.99,.45+i%3*.11)
                    ctx.arc(x,y,1+i%5*.61,0,Math.PI*2)
                    ctx.fill()
                }
                return
            }
            if (weatherFx.condition === "incursion") {
                for (let i=0;i<12;++i) {
                    const x = width*(i/11)
                    const side = i%2 ? -1 : 1
                    const coil = Math.sin(time*.85+i)*width*.06
                    const reach = height*(.14+i%6*.061)
                    ctx.beginPath()
                    ctx.moveTo(x,height*1.05)
                    ctx.bezierCurveTo(x+side*width*.16,height-reach*.39,x+coil-side*width*.08,height-reach*.88,
                        x+side*width*.10+coil,height-reach)
                    ctx.strokeStyle = i%3 ? "#b5190f26" : "#c90e091b"
                    ctx.lineCap = "round"
                    ctx.lineWidth = width*(.019+i%3*.007)
                    ctx.stroke()
                    ctx.strokeStyle = "#58452462"
                    ctx.lineWidth *= .33
                    ctx.stroke()
                }
                return
            }
            if (weatherFx.condition === "inferno") {
                for (let i = 0; i < 17; ++i) {
                    const flicker = .76 + .25*Math.sin(time*(3.3+i%5)+i*9)
                    const x = width*(i/16-.015)
                    const y = height*(1.01-i%4*.030)
                    const tall = height*(.12+i%6*.039)*flicker
                    const wide = width*(.039+i%4*.015)
                    const fire = ctx.createLinearGradient(x,y,x,y-tall)
                    fire.addColorStop(0,"#dcffb255")
                    fire.addColorStop(.63,"#80f64f27")
                    fire.addColorStop(1,"#00ea4525")
                    ctx.fillStyle = fire
                    ctx.beginPath()
                    ctx.moveTo(x-wide,y)
                    ctx.bezierCurveTo(x-wide,y-tall*.32,x+wide*.54,y-tall*.36,x-wide*.26,y-tall)
                    ctx.bezierCurveTo(x+wide*.53,y-tall*.68,x+wide*.16,y-tall*.31,x+wide,y)
                    ctx.fill()
                }
                for (let i = 0; i < 36; ++i) {
                    const drift = (time*(.12+i%4*.021)+i*.117)%1
                    const x = width*((i*.381966)%1)+Math.sin(drift*7+i)*17
                    const y = height*(1.04-drift*.84)
                    ctx.globalAlpha = (1-drift)*.82
                    ctx.fillStyle = i%4 ? "#ff8953" : "#ffe6a0"
                    ctx.fillRect(x,y,2+i%3,3+i%4)
                }
                return
            }
            if (weatherFx.condition === "meteor") {
                for (let i = 0; i < 23; i += 1) {
                    const progress = (time * (.15 + i % 4 * .05) + i * .143) % 1
                    const x = ((i * 133.7 + progress * width * .61) % (width * 1.1)) - width * .05
                    const y = (i * 67 % (height * .59)) + progress * height * .19
                    const tail = 14 + i % 6 * 7
                    const glow = ctx.createLinearGradient(x, y, x - tail, y - tail * .47)
                    glow.addColorStop(0, "#ffffc496")
                    glow.addColorStop(1, "#00cc8188")
                    ctx.beginPath()
                    ctx.strokeStyle = glow
                    ctx.globalAlpha = Math.sin(progress * Math.PI) * .72
                    ctx.lineWidth = i % 3 ? 1 : 2
                    ctx.moveTo(x, y)
                    ctx.lineTo(x - tail, y - tail * .47)
                    ctx.stroke()
                }
                ctx.globalAlpha = 1
                return
            }
            for (let i = 0; i < 101; i += 1) {
                const speed = 385 + (i % 5) * 125
                const x = ((i * 123.31 - time * speed * .19) % width + width) % width
                const y = (i * 97.51 + time * speed) % height
                const length = 14 + i % 7 * 4
                ctx.beginPath()
                ctx.strokeStyle = Qt.rgba(.65, .80, .98, .12 + (i % 7) * .035)
                ctx.lineWidth = i % 3 ? 1 : 1.8
                ctx.moveTo(x, y)
                ctx.lineTo(x - length * .21, y + length)
                ctx.stroke()
            }
        }
    }
}

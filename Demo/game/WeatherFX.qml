import QtQuick

Item {
    id: weatherFx
    objectName: sky ? "weatherLighting" : "weatherEffects"
    required property string condition
    required property real time
    required property bool motion
    property bool ultra:false
    property bool sky:false
    property real fogDensity:1
    property real nearVisibility:.38
    readonly property bool redNight:condition==="bloodMoon"

    property real gust: 0

    Rectangle {
        anchors.fill: parent
        visible: weatherFx.sky && ["night","bloodMoon","rain","thunder","fog","inferno","winter","incursion"].includes(weatherFx.condition)
        gradient: Gradient {
            GradientStop { position: 0; color: weatherFx.condition === "fog" ? "#65737d8b" : weatherFx.redNight ? "#ac731027" : weatherFx.condition === "inferno" ? "#75381821" : weatherFx.condition === "incursion" ? "#bb130a22" : weatherFx.condition === "night" ? "#ba0a193d" : "#54435a71" }
            GradientStop { position: .50; color: weatherFx.condition === "fog" ? "#d09da5ac" : weatherFx.redNight ? "#82501225" : weatherFx.condition === "inferno" ? "#30b64027" : weatherFx.condition === "incursion" ? "#8722143b" : weatherFx.condition === "night" ? "#74071138" : "#41353b59" }
            GradientStop { position: 1; color: weatherFx.condition === "fog" ? Qt.rgba(.41,.45,.48,.83*(1-weatherFx.nearVisibility))
                    : weatherFx.redNight ? "#9b2a0b1a" : weatherFx.condition === "inferno" ? "#a5d64614" : weatherFx.condition === "winter" ? "#77739cc5" : weatherFx.condition === "night" ? "#6a101a30" : "#46324958" }
        }
    }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: parent.height * .56
        visible: weatherFx.sky && weatherFx.condition === "night"
        opacity: weatherFx.motion ? .42 + Math.sin(weatherFx.time * .48) * .09 : .42
        gradient: Gradient {
            GradientStop { position: 0; color: "#426279c3" }
            GradientStop { position: 1; color: "transparent" }
        }
    }
    Rectangle {
        anchors.fill:parent
        visible:!weatherFx.sky && weatherFx.condition==="fog"
        opacity:weatherFx.ultra ? .74 : 1
        gradient:Gradient {
            GradientStop {position:0;color:Qt.rgba(.47,.50,.54,.24*weatherFx.fogDensity)}
            GradientStop {position:.44;color:Qt.rgba(.55,.58,.62,Math.min(.89,.59*weatherFx.fogDensity))}
            GradientStop {position:.72;color:Qt.rgba(.46,.49,.53,.67*weatherFx.fogDensity*(1-weatherFx.nearVisibility*.5))}
            GradientStop {position:1;color:Qt.rgba(.34,.39,.43,.60*weatherFx.fogDensity*(1-weatherFx.nearVisibility))}
        }
    }
    EffectCanvas {
        id: rain
        anchors.fill: parent
        visible: !weatherFx.sky && ["rain","thunder","fog","meteor","inferno","winter","incursion","windy","glitch"].includes(weatherFx.condition)
        onVisibleChanged: if (visible) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: weatherFx
            function onTimeChanged() { if (rain.visible && weatherFx.motion) rain.requestPaint() }
            function onConditionChanged() { if (rain.visible) rain.requestPaint() }
            function onGustChanged() { if (rain.visible) rain.requestPaint() }
            function onUltraChanged() { if (rain.visible) rain.requestPaint() }
            function onMotionChanged() { if (rain.visible) rain.requestPaint() }
        }

        function layeredFog(ctx, time) {
            for (let layer=0; layer<3; ++layer) {
                const bankY = height*(.39+layer*.20)
                const thickness = height*(.13+layer*.045)
                for (let plume=0; plume<5; ++plume) {
                    const drift = ((plume*.297+time*(.010+layer*.009)+layer*.371)%1.51)-.25
                    const x = width*drift
                    const wave = Math.sin(time*(.21+layer*.08)+plume*2.8)
                    const y = bankY + thickness*(wave*.48+(plume%3-1)*.44)
                    const breadth = width*(.31+layer*.033+plume%3*.07)
                    const flattening = thickness/breadth*(.62+plume%3*.13)
                    ctx.save()
                    ctx.translate(x,y)
                    ctx.scale(1,flattening)
                    const vapor = ctx.createRadialGradient(0,0,0,0,0,breadth)
                    vapor.addColorStop(0,layer === 0 ? "#84bac6cf" : layer === 1 ? "#788996a6" : "#72636679")
                    vapor.addColorStop(.40,layer === 0 ? "#4f9eafbe" : layer === 1 ? "#5babb6c1" : "#498a92a2")
                    vapor.addColorStop(.73,layer === 0 ? "#259bacbb" : "#357d889c")
                    vapor.addColorStop(1,"transparent")
                    ctx.globalAlpha = .68+wave*.17
                    ctx.fillStyle = vapor
                    ctx.fillRect(-breadth,-breadth,breadth*2,breadth*2)
                    ctx.restore()
                }
            }
        }

        function layeredRain(ctx, time, storm) {
            const scale = Math.max(.65,Math.min(1.7,height/800))
            const wind = storm ? .31 : .20
            const wrapX = width+180, wrapY = height+130
            ctx.lineCap = "round"
            for (let layer=0; layer<3; ++layer) {
                const count = (storm ? 69 : 52)-layer*15
                const speed = (240+layer*395)*scale
                ctx.beginPath()
                for (let i=0; i<count; ++i) {
                    const index = i+layer*59
                    const fall = time*speed*(.81+i%9*.044)
                    const x = ((index*173.31-fall*wind)%wrapX+wrapX)%wrapX-80
                    const y = (index*103.23+fall)%wrapY-75
                    const tail = (11+layer*14+i%7*(2+layer))*scale*(storm ? 1.30 : 1)
                    ctx.moveTo(x,y)
                    ctx.lineTo(x-tail*wind,y+tail)
                }
                ctx.strokeStyle = ["#3883a8d3", "#679bbde2", "#84c0ddef"][layer]
                ctx.lineWidth = scale*(.78+layer*.63)
                ctx.stroke()
                if (layer === 2) {
                    ctx.strokeStyle = "#425b83b1"
                    ctx.lineWidth *= 2.8
                    ctx.stroke()
                }
            }
            for (let i=0; i<(storm ? 19 : 12); ++i) {
                const age = (time*(.98+i%3*.48)+i*.713)%1
                if (age >= .44)
                    continue
                const depth = .61+(i*.873%1)*.39
                const x = width*((i*.618+Math.floor(time*(.98+i%3*.48)+i*.713)*.127)%1)
                const size = (.9+age*13)*(depth-.45)*scale
                const y = height*depth
                ctx.globalAlpha = (1-age/.44)*.80
                ctx.strokeStyle = "#b9dcec"
                ctx.lineWidth = Math.max(.7,scale*.80)
                ctx.beginPath()
                ctx.ellipse(x-size,y-size*.24,size*2,size*.48)
                ctx.moveTo(x,y)
                ctx.lineTo(x-size*.58,y-size*.98)
                ctx.moveTo(x+size*.31,y)
                ctx.lineTo(x+size*.78,y-size*.65)
                ctx.stroke()
            }
            ctx.globalAlpha = 1
        }

        onPaint: {
            const ctx = beginPaint()
            ctx.clearRect(0, 0, width, height)
            if (width <= 0 || height <= 0)
                return
            const time = weatherFx.motion ? weatherFx.time : 0
            if (weatherFx.condition === "fog") {
                if (weatherFx.ultra) {
                    layeredFog(ctx,time)
                    return
                }
                for (let bank=0;bank<6;bank++) {
                    const y=(.22+bank*.13+Math.sin(time*.063+bank)*.033)*height
                    const thick=(.14+bank%3*.035)*height
                    const haze=ctx.createLinearGradient(0,y-thick,0,y+thick)
                    haze.addColorStop(0,"transparent")
                    haze.addColorStop(.48,Qt.rgba(.69,.72,.75,.11+bank%3*.04))
                    haze.addColorStop(.70,Qt.rgba(.52,.57,.63,.09))
                    haze.addColorStop(1,"transparent")
                    ctx.fillStyle=haze
                    ctx.fillRect(0,y-thick,width,thick*2)
                }
                return
            }
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
            if (weatherFx.condition!=="rain" && weatherFx.condition!=="thunder") return
            const storm=weatherFx.condition==="thunder"
            if (weatherFx.ultra) {
                layeredRain(ctx,time,storm)
                return
            }
            for (let i = 0; i < (storm ? 158 : 101); i += 1) {
                const speed = 385 + (i % 5) * 125
                const x = ((i * 123.31 - time * speed * .19) % width + width) % width
                const y = (i * 97.51 + time * speed) % height
                const length = (storm ? 24 : 14) + i % 7 * 4
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

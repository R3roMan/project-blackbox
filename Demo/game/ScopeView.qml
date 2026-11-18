import QtQuick

Canvas {
    id: view
    objectName: "weaponScope"
    required property var sight
    required property point centre
    required property color ink
    required property real magnification
    required property real readiness
    readonly property bool crosshair: ["survey","marksman","ledger","oath"].includes(sight.style)
    readonly property real lensRadius: Math.min(width,height) * (crosshair ? .224 : .247)

    visible: magnification > 1.01
    onVisibleChanged: if (visible) requestPaint()
    onCentreChanged: if (visible) requestPaint()
    onMagnificationChanged: if (visible) requestPaint()
    onSightChanged: if (visible) requestPaint()
    onReadinessChanged: if (visible) requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    Text {
        x: view.centre.x - width/2
        y: view.centre.y - view.lensRadius + 12
        opacity: Math.min(1,(view.magnification-1)*6)
        color: "#e0e6f1"
        font.family: "IBM Plex Mono"
        font.pixelSize: 11
        text: view.sight.label.toUpperCase() + "  ×" + view.sight.zoom.toFixed(2)
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0,0,width,height)
        if (!visible)
            return
        const rune = sight.style === "arc" || sight.style === "melee"
        const radius = lensRadius
        const alpha = Math.min(1,(magnification-1)*6)
        ctx.globalAlpha = alpha
        ctx.beginPath()
        ctx.rect(0,0,width,height)
        ctx.moveTo(centre.x+radius,centre.y)
        ctx.arc(centre.x,centre.y,radius,0,Math.PI*2,true)
        ctx.fillStyle = "#9e0a0c16"
        ctx.fill()
        ctx.translate(centre.x,centre.y)
        ctx.beginPath()
        ctx.arc(0,0,radius,0,Math.PI*2)
        ctx.lineWidth = rune ? 3 : 7
        ctx.strokeStyle = "#172437"
        ctx.stroke()
        ctx.lineWidth = 1.3
        ctx.strokeStyle = ink
        ctx.stroke()

        ctx.beginPath()
        if (crosshair || sight.style === "beam") {
            for (const sign of [-1,1]) {
                ctx.moveTo(sign*9,0)
                ctx.lineTo(sign*radius*.88,0)
                ctx.moveTo(0,sign*9)
                ctx.lineTo(0,sign*radius*.81)
                for (let i = 1; i <= sight.ticks; ++i) {
                    const gap = i * radius*.69/(sight.ticks+1)
                    ctx.moveTo(sign*gap,-4)
                    ctx.lineTo(sign*gap,4)
                    ctx.moveTo(-4,sign*gap)
                    ctx.lineTo(4,sign*gap)
                }
            }
        } else if (rune || sight.style === "buck") {
            const sides = sight.style === "melee" ? 4 : sight.style === "buck" ? 8 : 6
            for (let i = 0; i < sides; ++i) {
                const angle = i*Math.PI*2/sides - Math.PI*.25
                const x = Math.cos(angle)
                const y = Math.sin(angle)
                ctx.moveTo(radius*.25*x,radius*.25*y)
                ctx.lineTo(radius*.39*x,radius*.39*y)
                ctx.lineTo(radius*.47*Math.cos(angle+.14),radius*.47*Math.sin(angle+.14))
            }
        } else {
            ctx.moveTo(-radius*.35,21)
            ctx.lineTo(-radius*.12,21)
            ctx.lineTo(-radius*.08,13)
            ctx.moveTo(radius*.35,21)
            ctx.lineTo(radius*.12,21)
            ctx.lineTo(radius*.08,13)
            if (sight.style === "post") {
                ctx.moveTo(0,17)
                ctx.lineTo(0,radius*.55)
            }
        }
        ctx.strokeStyle = "#dfdce6"
        ctx.lineWidth = 1.2
        ctx.stroke()

        const special = {cryo:6,thermal:3,voltage:4,eclipse:12,compass:4,fault:5,prism:7,ledger:4,oath:4}[sight.style]
        if (special) {
            ctx.strokeStyle = ink
            ctx.lineWidth = 1.7
            ctx.beginPath()
            for (let i=0; i<special; ++i) {
                const angle=i*Math.PI*2/special-Math.PI/2
                const inner=radius*(sight.style === "cryo" ? .26 : .38)
                const outer=radius*(sight.style === "voltage" ? .73 : .64)
                ctx.moveTo(Math.cos(angle)*inner,Math.sin(angle)*inner)
                ctx.lineTo(Math.cos(angle)*outer,Math.sin(angle)*outer)
                ctx.lineTo(Math.cos(angle+.12)*(outer-12),Math.sin(angle+.12)*(outer-12))
            }
            ctx.stroke()
            if (sight.style === "eclipse") {
                ctx.beginPath()
                ctx.arc(radius*.12,0,radius*.53,.45,Math.PI*1.82)
                ctx.stroke()
            } else if (sight.style === "thermal") {
                for (let i=0; i<9; ++i) {
                    ctx.fillStyle=i<Math.round(readiness*9) ? ink : "#5c4854"
                    ctx.fillRect(-radius*.54+i*radius*.12,radius*.64,5,9+i%3*3)
                }
            } else if (sight.style === "ledger") {
                ctx.strokeRect(-radius*.53,-radius*.32,radius*1.06,radius*.64)
                ctx.font="18px serif"
                ctx.fillStyle=ink
                ctx.fillText("¤",radius*.59,6)
            } else if (sight.style === "fault") {
                ctx.beginPath()
                ctx.moveTo(-radius*.23,radius*.56)
                ctx.lineTo(-radius*.08,radius*.39)
                ctx.lineTo(radius*.04,radius*.52)
                ctx.lineTo(radius*.21,radius*.31)
                ctx.stroke()
            }
        }

        ctx.fillStyle = ink
        ctx.beginPath()
        ctx.arc(0,0,sight.style === "dot" ? 3 : 1.8,0,Math.PI*2)
        ctx.fill()
        ctx.strokeStyle = ink
        ctx.lineWidth = 2.7
        ctx.beginPath()
        ctx.arc(0,0,radius*.94,Math.PI*.30,Math.PI*(.30 + readiness*.40))
        ctx.stroke()
    }
}

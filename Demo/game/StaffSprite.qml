import QtQuick

Canvas {
    id: staff
    required property string kind
    required property color tint
    property real charge: 0
    property real cast:0
    onCastChanged:requestPaint()
    property real clock: 0
    property real attack: 0
    onKindChanged: requestPaint()
    onTintChanged: requestPaint()
    onChargeChanged: requestPaint()
    onClockChanged: requestPaint()
    onAttackChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0,0,width,height)
        ctx.scale(width / 336, height / 170)
        ctx.translate(92 + attack*22,46 + attack*8)
        ctx.rotate(.23 + attack*.087-Math.sin(cast*Math.PI)*.22)
        ctx.fillStyle = "#262630"
        ctx.fillRect(-7,0,15,151)
        ctx.fillStyle = "#847d8c"
        ctx.fillRect(-4,6,3,136)
        ctx.fillStyle = "#4d2637"
        ctx.fillRect(-10,82,21,51)
        for (let i = 0; i < 7; i += 1) {
            ctx.fillStyle = i % 2 ? "#2d2633" : "#766066"
            ctx.fillRect(-10,84+i*7,20,3)
        }
        const sides = kind === "wind" || kind === "aurora" ? 8 : kind === "stun" ? 4 : kind === "avatar" ? 6 : 3
        const palette = ["#8afad6","#ff7849","#99e6ff","#d684ff","#e4a365","#cc8dff"]
        for (let i = 0; i < sides; i += 1) {
            const angle = i * Math.PI * 2 / sides + clock * (1 + charge*1.4)
            const x = Math.cos(angle)*27
            const y = Math.sin(angle)*23
            ctx.strokeStyle = "#898091"
            ctx.lineWidth = 6
            ctx.beginPath()
            ctx.moveTo(0,4)
            ctx.lineTo(x,y)
            ctx.stroke()
            ctx.fillStyle = kind === "avatar" ? palette[i] : Qt.lighter(tint,1 + charge*.44)
            ctx.beginPath()
            ctx.arc(x,y,3 + charge*3,0,Math.PI*2)
            ctx.fill()
        }
        ctx.fillStyle = Qt.lighter(tint,1 + charge*.56)
        ctx.beginPath()
        ctx.moveTo(-13,-4)
        ctx.lineTo(0,-23)
        ctx.lineTo(14,-6)
        ctx.lineTo(0,12)
        ctx.closePath()
        ctx.fill()
        if (kind === "wind" || charge >= 1) {
            ctx.globalAlpha = .5 * charge
            ctx.strokeStyle = tint
            for (let i = 0; i < 3; i += 1) {
                ctx.beginPath()
                ctx.arc(0,-4,21 + charge*13 + i*5, clock*2+i*2.1, clock*2+i*2.1+1.66)
                ctx.lineWidth = 2 + charge*3
                ctx.stroke()
            }
        }
    }
}

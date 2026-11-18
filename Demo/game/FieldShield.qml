import QtQuick

Canvas {
    id: shield
    objectName: "fieldShieldVisual"
    required property bool active
    required property bool raised
    required property real age
    required property real impact
    required property color tint
    required property bool motion
    required property string mode

    visible: active && (raised || impact > 0)
    onVisibleChanged: if (visible) requestPaint()
    onAgeChanged: if (visible && age < .2) requestPaint()
    onRaisedChanged: if (visible) requestPaint()
    onImpactChanged: if (visible) requestPaint()
    onWidthChanged: if (visible) requestPaint()
    onHeightChanged: if (visible) requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0,0,width,height)
        if (!visible)
            return
        const rise = motion && raised ? Math.max(0,Math.min(1,age/.16)) : 1
        const stability = raised ? 1 : Math.min(1,impact*2.4)
        const shock = impact/.38
        const span = Math.min(width*.39,height*.66)
        const lift = Math.min(height*.37,width*.26) * (.89 + rise*.11)
        ctx.translate(width*.5,height*(.49 + (1-rise)*.12))
        const fill = ctx.createLinearGradient(0,-lift,0,lift)
        fill.addColorStop(0,Qt.rgba(tint.r,tint.g,tint.b,.22+shock*.24))
        fill.addColorStop(.48,Qt.rgba(tint.r,tint.g,tint.b,.03+shock*.10))
        fill.addColorStop(1,Qt.rgba(tint.r,tint.g,tint.b,.23+shock*.29))
        ctx.globalAlpha = (.25 + rise*.75) * stability
        ctx.beginPath()
        ctx.moveTo(-span,-lift*.46)
        ctx.lineTo(-span*.72,-lift*.83)
        ctx.lineTo(0,-lift)
        ctx.lineTo(span*.72,-lift*.83)
        ctx.lineTo(span,-lift*.46)
        ctx.lineTo(span,lift*.22)
        ctx.quadraticCurveTo(span*.68,lift*.84,0,lift)
        ctx.quadraticCurveTo(-span*.68,lift*.84,-span,lift*.22)
        ctx.closePath()
        ctx.fillStyle = fill
        ctx.fill()
        ctx.strokeStyle = Qt.rgba(tint.r,tint.g,tint.b,.34+shock*.40)
        ctx.lineWidth = mode === "bulwark" ? 10 : 6
        ctx.stroke()
        ctx.lineWidth = 1.5
        ctx.strokeStyle = Qt.lighter(tint,1.38)
        ctx.stroke()
        ctx.beginPath()
        for (const side of [-1,1]) {
            ctx.moveTo(side*span*.91,-lift*.37)
            ctx.lineTo(side*span*.67,-lift*.67)
            ctx.lineTo(side*span*.19,-lift*.81)
            ctx.moveTo(side*span*.91,lift*.18)
            ctx.quadraticCurveTo(side*span*.67,lift*.72,side*span*.22,lift*.83)
            for (let index = 0; index < 4; ++index) {
                const y = lift*(-.26 + index*.16)
                ctx.moveTo(side*span*.91,y)
                ctx.lineTo(side*span*.80,y+lift*.05)
            }
        }
        ctx.strokeStyle = Qt.rgba(tint.r,tint.g,tint.b,.45)
        ctx.stroke()
        if (shock > 0) {
            const edge = span * (.62 + (1-shock)*.22)
            ctx.strokeStyle = Qt.rgba(1,1,1,shock*.8)
            ctx.lineWidth = 1.35
            ctx.beginPath()
            ctx.ellipse(-edge,-lift*.57,edge*2,lift*1.22)
            ctx.stroke()
            for (let i = 0; i < 12; ++i) {
                const angle = i * Math.PI/6
                const radius = .65 + (1-shock)*.30
                const x = Math.cos(angle)*span*radius
                const y = Math.sin(angle)*lift*radius
                ctx.beginPath()
                ctx.moveTo(x,y)
                ctx.lineTo(x+Math.cos(angle)*14*shock,y+Math.sin(angle)*23*shock)
                ctx.stroke()
            }
        }
    }
}

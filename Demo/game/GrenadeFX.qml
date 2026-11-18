import QtQuick
import "Elements.js" as Elements

Canvas {
    id: flight
    required property var run
    required property int revision
    required property string frontId
    required property point muzzle
    required property bool active
    property var colors: ({ cryogrenade:"#90d7ff", nullgrenade:"#b99eff", gravitywell:"#e6a3ff", frag:"#ffcb8a", launcher:"#ffab63" })

    onRevisionChanged: {
        if (active && (run.grenades.length || run.blast && run.blast.life > 0))
            requestPaint()
        else if (visible)
            requestPaint()
    }
    visible: {
        revision
        return active && (run.grenades.length > 0 || !!run.blast && run.blast.life > 0)
    }
    onVisibleChanged: if (visible) requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        for (const grenade of run.grenades) {
            if (grenade.front !== frontId)
                continue
            const start = grenade.kind === "launcher" ? muzzle : Qt.point(width * .58, height * .80)
            const endX = grenade.x * width
            const endY = grenade.y * height
            const age = 1 - grenade.remaining / grenade.duration
            if (grenade.effect && grenade.effect.spell) {
                const kind = grenade.effect.element
                const tint = Elements.kinds[kind].color
                ctx.globalAlpha = .94
                ctx.strokeStyle = tint
                if (kind === "burn" || kind === "electric") {
                    const tip = endY * age
                    ctx.beginPath()
                    ctx.moveTo(endX + (kind === "burn" ? width*.18 : 0), 0)
                    for (let i = 1; i <= 7; i += 1)
                        ctx.lineTo(endX + (kind === "burn" ? width*.18*(1-i/7) : Math.sin(i*17)*16), tip*i/7)
                    ctx.lineWidth = kind === "burn" ? 23 : 15
                    ctx.stroke()
                    ctx.strokeStyle = "#fff5dd"
                    ctx.lineWidth = 4
                    ctx.stroke()
                    ctx.fillStyle = tint
                    ctx.beginPath()
                    ctx.arc(endX,tip,kind === "burn" ? 22 : 8,0,Math.PI*2)
                    ctx.fill()
                } else {
                    const size = height * (.048 + age*.15)
                    for (let ring = 0; ring < 3; ring += 1) {
                        ctx.beginPath()
                        ctx.arc(endX,endY,size + ring*10,age*8+ring*2,age*8+ring*2+3.4)
                        ctx.lineWidth = 2 + 6*age
                        ctx.stroke()
                    }
                }
                continue
            }
            for (let i = 0; i < 6; i += 1) {
                const t = Math.max(0, age - i * .044)
                const x = start.x + (endX - start.x) * t
                const y = start.y + (endY - start.y) * t - Math.sin(t * Math.PI) * height * .20
                ctx.beginPath()
                ctx.arc(x, y, 6 - i * .79, 0, Math.PI * 2)
                ctx.fillStyle = flight.colors[grenade.kind] || "#ffcc87"
                ctx.globalAlpha = 1 - i * .14
                ctx.fill()
            }
        }
        const blast = run.blast
        if (blast && blast.front === frontId && blast.life > 0) {
            const age = 1 - blast.life / .45
            const radius = Math.max(14, height * blast.radius / 1850 * (.25 + age * .7))
            ctx.beginPath()
            ctx.arc(blast.x * width, blast.y * height, radius, 0, Math.PI * 2)
            ctx.strokeStyle = flight.colors[blast.kind] || "#ffcc87"
            ctx.lineWidth = 9 * (1 - age) + 1
            ctx.globalAlpha = .94 * (1 - age)
            ctx.stroke()
        }
    }
}

import QtQuick

Item {
    id: effects
    required property real time
    required property bool motion
    required property real distortion
    required property bool projected
    required property int shield
    required property real shatter
    property real recharge: 0
    property bool voidStorm: false

    Rectangle {
        objectName: "blueShield"
        anchors.fill: parent
        visible: effects.shield > 0
        opacity: Math.min(1, (effects.shield === 1 ? .72 : .94)
            + (effects.motion ? effects.recharge * .32 : 0))
        radius: 22
        border.color: "#ab80d7ff"
        border.width: 5
        gradient: Gradient {
            GradientStop { position: 0; color: "#74336dc1" }
            GradientStop { position: .22; color: "#332452aa" }
            GradientStop { position: .62; color: "#37186ac6" }
            GradientStop { position: 1; color: "#7c2f8bc5" }
        }
    }

    Canvas {
        id: particles
        objectName: "shieldShatter"
        anchors.fill: parent
        visible: effects.shatter > 0 || effects.voidStorm || effects.projected && effects.distortion > 0
        onVisibleChanged: if (visible) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: effects
            function onTimeChanged() { if (particles.visible) particles.requestPaint() }
            function onShatterChanged() { particles.requestPaint() }
            function onVoidStormChanged() { particles.requestPaint() }
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            if ((effects.projected && effects.distortion > 0) || effects.voidStorm) {
                const phase = effects.motion ? Math.floor(effects.time * 8) : 0
                const strips = effects.voidStorm && !effects.projected ? 11 : 26
                const colors = effects.voidStorm ? ["#a8250b1b", "#74c62246", "#5e372a6c"]
                    : ["#a7331642", "#8bba4276", "#73446fba"]
                for (let i = 0; i < strips; i += 1) {
                    const salt = i * 106.3 + phase * 33.7
                    const start = (salt * .64 % width)
                    const y = salt % height
                    ctx.fillStyle = colors[i%3]
                    ctx.fillRect(start, y, Math.min(width - start, 40 + (i * 73) % width), 3 + i % 8 * 6)
                    if (i % 3 === 0) {
                        ctx.fillStyle = "#661a142a"
                        ctx.fillRect(0, y + 7, width, 13 + i % 5 * 9)
                    }
                }
            }
            if (effects.shatter > 0) {
                const age = 1 - effects.shatter / .47
                ctx.globalAlpha = .92 * (1 - age)
                for (let i = 0; i < 29; i += 1) {
                    const angle = i * Math.PI * 2 / 29
                    const power = .66 + (i % 4) * .22
                    const push = effects.motion ? age * (118 + i % 9 * 12) : 0
                    const x = width * .5 + Math.cos(angle) * (width * .24 * power + push)
                    const y = height * .48 + Math.sin(angle) * (height * .32 * power + push)
                    const size = 8 + i % 6 * 3.4
                    ctx.beginPath()
                    ctx.moveTo(x + Math.cos(angle) * size, y + Math.sin(angle) * size)
                    ctx.lineTo(x - size * .64, y + size * .54)
                    ctx.lineTo(x + size * .11, y - size * .77)
                    ctx.closePath()
                    ctx.fillStyle = i % 2 ? "#65bfff" : "#c5f3ff"
                    ctx.fill()
                    ctx.strokeStyle = "#cff6ff"
                    ctx.lineWidth = 1.2
                    ctx.stroke()
                }
            }
        }
    }
}

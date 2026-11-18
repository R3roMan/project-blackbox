import QtQuick
import "../ui" as Ui

Item {
    id: vignette
    objectName: "healthVignette"

    required property real healthRatio
    required property real pulse
    required property real hurt
    required property int injury

    readonly property real lowHealth: healthRatio <= .35 ? .16 + pulse * .32 : 0
    opacity: Math.min(.88, (healthRatio < 1 ? .14 + (1 - healthRatio) * .23 : 0) + lowHealth + hurt)
    visible: opacity > 0

    Canvas {
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onVisibleChanged: if (visible) requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.scale(width, height)
            const red = ctx.createRadialGradient(.50, .49, .11, .50, .49, .73)
            red.addColorStop(0, "#00ff2344")
            red.addColorStop(.47, "#00ff2344")
            red.addColorStop(.75, "#a7d71f42")
            red.addColorStop(1, "#f8ae122e")
            ctx.fillStyle = red
            ctx.fillRect(0, 0, 1, 1)
        }
    }

    Repeater {
        model: 4
        Ui.BloodStain {
            required property int index
            width: Math.min(vignette.width * .29, 350) * (index % 2 ? .88 : 1)
            height: Math.min(vignette.height * .27, width * .62)
            mirrorX: index % 2 === 1
            mirrorY: index >= 2
            x: mirrorX ? vignette.width - width : 0
            y: mirrorY ? vignette.height - height : 0
            opacity: Math.min(1,vignette.hurt * 1.7 + vignette.lowHealth + (1 - vignette.healthRatio)*.64)
            visible: opacity > 0
            seed: index * 13 + vignette.injury % 17
        }
    }
}

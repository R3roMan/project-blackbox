import QtQuick
import "HarvesterArt.js" as Ink

Canvas {
    required property real phase
    required property real opening
    width:384
    height:384
    onPhaseChanged:requestPaint()
    onOpeningChanged:requestPaint()
    onPaint: {
        const ctx=getContext("2d")
        ctx.reset()
        ctx.clearRect(0,0,width,height)
        ctx.scale(width,height)
        Ink.draw(ctx,phase,opening)
    }
}

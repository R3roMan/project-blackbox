import QtQuick

Item {
    id:effect
    property int textureLimit:1600
    property int frameRate:30
    property real lastPaintAt:0
    readonly property real textureScale:Math.min(1,textureLimit/(Math.max(1,width)*Math.max(1,Screen.devicePixelRatio)))
    signal paint()

    function requestPaint() {
        if (visible && !redraw.running)
            redraw.start()
    }

    function imageReady(url) {
        if (surface.isImageLoaded(url)) return true
        if (!surface.isImageLoading(url) && !surface.isImageError(url)) surface.loadImage(url)
        return false
    }

    function beginPaint() {
        const context=surface.getContext("2d")
        context.reset()
        context.scale(textureScale,textureScale)
        return context
    }

    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onVisibleChanged:if (visible) requestPaint()
    Component.onCompleted:requestPaint()
    Timer {
        id:redraw
        interval:Math.max(1,1000/effect.frameRate-(Date.now()-effect.lastPaintAt))
        onTriggered: {
            effect.lastPaintAt=Date.now()
            surface.requestPaint()
        }
    }
    Canvas {
        id:surface
        width:Math.max(1,Math.round(effect.width*effect.textureScale))
        height:Math.max(1,Math.round(effect.height*effect.textureScale))
        scale:1/effect.textureScale
        transformOrigin:Item.TopLeft
        smooth:true
        renderStrategy:Canvas.Threaded
        onAvailableChanged:if (available) effect.requestPaint()
        onImageLoaded:effect.requestPaint()
        onPaint:effect.paint()
    }
}

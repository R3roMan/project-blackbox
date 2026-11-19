import QtQuick
import "ViewTurn.js" as ViewTurn

// Carry a narrow strip of the departing scenery across the corner. The strip
// includes the current sky and shadows, so pine branches and walls feather
// into the incoming scene even with Qt's software renderer and custom images.
Item {
    id:join
    required property bool active
    required property Item outgoing
    required property string direction
    required property real progress
    property string lightingKey:""
    property color seamTint:"transparent"
    property var snapshot:null
    property int capture:0
    readonly property bool horizontal:direction==="left" || direction==="right"
    readonly property bool positive:direction==="right" || direction==="down"
    readonly property real span:horizontal ? width : height
    readonly property real boundary:span*ViewTurn.seam(direction,progress)
    readonly property real fraction:horizontal ? .13 : .20
    readonly property real feather:span*fraction*Math.sin(progress*Math.PI)
    readonly property size captureSize:Qt.size(Math.min(900,width),Math.max(1,Math.round(Math.min(900,width)*height/Math.max(1,width))))
    function updateCapture() {
        const token=++capture
        snapshot=null
        if (!active || !outgoing || !width || !height) return
        outgoing.grabToImage(function(result) {
            if (capture===token && active) snapshot=result
        },captureSize)
    }
    onActiveChanged:Qt.callLater(updateCapture)
    onOutgoingChanged:if(active) Qt.callLater(updateCapture)
    onLightingKeyChanged:if(active) Qt.callLater(updateCapture)
    onSnapshotChanged: {
        if (strip.source) strip.unloadImage(strip.source)
        strip.source=snapshot ? String(snapshot.url) : ""
        if (strip.source) strip.loadImage(strip.source)
    }
    visible:active && feather>1
    Canvas {
        id:strip
        property string source:""
        property bool loaded:false
        x:join.horizontal ? join.boundary-(join.positive ? 0 : join.feather) : 0
        y:join.horizontal ? 0 : join.boundary-(join.positive ? 0 : join.feather)
        width:Math.max(1,join.captureSize.width*(join.horizontal ? join.fraction : 1))
        height:Math.max(1,join.captureSize.height*(join.horizontal ? 1 : join.fraction))
        renderStrategy:Canvas.Threaded
        transform:Scale {
            xScale:(join.horizontal ? join.feather : join.width)/strip.width
            yScale:(join.horizontal ? join.height : join.feather)/strip.height
        }
        onSourceChanged:loaded=false
        onImageLoaded:requestPaint()
        onAvailableChanged:if (available && source) requestPaint()
        onPaint: {
            if (!source || !isImageLoaded(source)) return
            const c=getContext("2d")
            const sw=join.captureSize.width, sh=join.captureSize.height
            const cropW=join.horizontal ? width : sw, cropH=join.horizontal ? sh : height
            const sx=join.horizontal && join.positive ? sw-cropW : 0
            const sy=!join.horizontal && join.positive ? sh-cropH : 0
            c.reset()
            c.clearRect(0,0,width,height)
            c.save()
            c.translate(join.horizontal ? width : 0,join.horizontal ? 0 : height)
            c.scale(join.horizontal ? -1 : 1,join.horizontal ? 1 : -1)
            c.drawImage(source,sx,sy,cropW,cropH,0,0,width,height)
            c.restore()
            c.globalCompositeOperation="destination-in"
            const dx=join.horizontal ? width : 0, dy=join.horizontal ? 0 : height
            const fade=join.positive ? c.createLinearGradient(0,0,dx,dy) : c.createLinearGradient(dx,dy,0,0)
            fade.addColorStop(0,"white")
            fade.addColorStop(.38,"#a0ffffff")
            fade.addColorStop(.75,"#2dffffff")
            fade.addColorStop(1,"transparent")
            c.fillStyle=fade
            c.fillRect(0,0,width,height)
            loaded=true
        }
    }
    Rectangle {
        visible:join.seamTint.a>0
        x:join.horizontal ? join.boundary-join.feather : 0
        y:join.horizontal ? 0 : join.boundary-join.feather
        width:join.horizontal ? join.feather*2 : join.width
        height:join.horizontal ? join.height : join.feather*2
        opacity:.84*Math.sin(join.progress*Math.PI)
        gradient:Gradient {
            orientation:join.horizontal ? Gradient.Horizontal : Gradient.Vertical
            GradientStop {position:0;color:"transparent"}
            GradientStop {position:.23;color:Qt.rgba(join.seamTint.r,join.seamTint.g,join.seamTint.b,.24)}
            GradientStop {position:.5;color:join.seamTint}
            GradientStop {position:.77;color:Qt.rgba(join.seamTint.r,join.seamTint.g,join.seamTint.b,.24)}
            GradientStop {position:1;color:"transparent"}
        }
    }
}

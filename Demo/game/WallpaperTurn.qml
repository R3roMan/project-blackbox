import QtQuick
import "Rules.js" as Rules

Item {
    id: backdrop
    required property url artDirectory
    required property string frontId
    required property string previousFront
    required property string direction
    required property real progress
    required property bool lab
    property var sources:({})
    function defaultFor(front) {return Qt.resolvedUrl(String(artDirectory)+Rules.front(front).art)}
    function fileFor(front) {return sources[front] || defaultFor(front)}
    property bool slide: true
    property string framing: "fill"
    property int quality: 0
    property real zoom: 1
    property string transitionStyle:"cinematic"
    readonly property bool abyssTransition:(frontId === "down" || previousFront === "down") && frontId !== previousFront

    readonly property bool moving: progress < 1 && !lab
    readonly property bool sliding:moving && slide && !abyssTransition && transitionStyle === "cinematic"
    readonly property int horizontal: direction === "left" ? -1 : direction === "right" ? 1 : 0
    readonly property int vertical: direction === "up" ? -1 : direction === "down" ? 1 : 0
    readonly property real pixelRatio: Math.max(1, Screen.devicePixelRatio)
    readonly property real sampleScale: Math.min(pixelRatio, quality > 0 ? quality / Math.max(1, height) : 8192 / Math.max(1, width))
    readonly property int pixelsWide: Math.max(1, Math.round(width * sampleScale * zoom))
    readonly property int pixelsHigh: Math.max(1, Math.round(height * sampleScale * zoom))

    component Wallpaper: Image {
        property url requestedSource
        property url fallbackSource
        property string failedSource:""
        source:failedSource===String(requestedSource) ? fallbackSource : requestedSource
        onRequestedSourceChanged:failedSource=""
        onStatusChanged:if(status===Image.Error && String(source)===String(requestedSource))failedSource=String(requestedSource)
        width: backdrop.width
        height: backdrop.height
        scale: backdrop.zoom
        smooth: true
        mipmap: true
        sourceSize: Qt.size(backdrop.pixelsWide, backdrop.pixelsHigh)
        fillMode: backdrop.framing === "stretch" ? Image.Stretch
            : backdrop.framing === "fit" ? Image.PreserveAspectFit : Image.PreserveAspectCrop
    }
    Wallpaper {
        visible:backdrop.moving
        opacity:backdrop.sliding ? 1 : 1-backdrop.progress
        scale:backdrop.zoom*(backdrop.moving && backdrop.abyssTransition ? 1+backdrop.progress*.30 : 1)
        x: backdrop.sliding ? -backdrop.horizontal * backdrop.progress * width : 0
        y: backdrop.sliding ? -backdrop.vertical * backdrop.progress * height : 0
        requestedSource: backdrop.fileFor(backdrop.previousFront)
        fallbackSource:backdrop.defaultFor(backdrop.previousFront)
    }
    Wallpaper {
        objectName: "activeWallpaper"
        visible:true
        opacity:backdrop.moving && !backdrop.sliding ? backdrop.progress : 1
        scale:backdrop.zoom*(backdrop.moving && backdrop.abyssTransition ? 1+(1-backdrop.progress)*.30 : 1)
        x: backdrop.horizontal * (backdrop.sliding ? 1 - backdrop.progress : 0) * width
        y: backdrop.vertical * (backdrop.sliding ? 1 - backdrop.progress : 0) * height
        requestedSource: backdrop.fileFor(backdrop.lab ? "right" : backdrop.frontId)
        fallbackSource:backdrop.defaultFor(backdrop.lab ? "right" : backdrop.frontId)
    }
}

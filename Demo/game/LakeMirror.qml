import QtQuick

ShaderEffect {
    id: mirror
    required property Item field
    required property string framing
    required property real zoom
    required property vector4d lightAndTime
    readonly property vector4d imageFrame:{
        const ratio=1672/941
        const fitted=framing==="fit" ? Math.min(width/ratio,height) : Math.max(width/ratio,height)
        const w=zoom*(framing==="stretch" ? width : fitted*ratio)/Math.max(1,width)
        const h=zoom*(framing==="stretch" ? height : fitted)/Math.max(1,height)
        return Qt.vector4d((1-w)*.5,(1-h)*.5,w,h)
    }
    property var waterMask:mask
    fragmentShader:Qt.resolvedUrl("shaders/lake-mirror.frag.qsb")
    Image {
        id:mask
        visible:false
        source:Qt.resolvedUrl("../assets/landscape/lake-mask.png")
    }
}

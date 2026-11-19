import QtQuick3D

PrincipledMaterial {
    property var surfaces:null
    property string finish:"hide"
    readonly property bool detailed:!!surfaces?.detailed
    normalMap:detailed ? surfaces[finish+"Normal"] : null
    normalStrength:finish==="hide" ? .82 : finish==="steel" ? .55 : .46
    roughnessMap:detailed ? surfaces[finish+"Finish"] : null
    roughnessChannel:Material.G
    occlusionMap:roughnessMap
    occlusionChannel:Material.R
    occlusionAmount:.67
    clearcoatAmount:detailed && finish==="steel" ? .40 : 0
    clearcoatRoughnessAmount:.29
}

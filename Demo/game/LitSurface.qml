import QtQuick3D

PrincipledMaterial {
    property var surfaces:null
    property string finish:"hide"
    readonly property bool detailed:!!surfaces?.detailed
    baseColorMap:detailed ? surfaces[finish+"Color"] ?? null : null
    normalMap:detailed ? surfaces[finish+"Normal"] : null
    normalStrength:({hide:.50,steel:.55,wing:.66,horn:.62,bone:.33,wood:.57,ice:.72})[finish] ?? .46
    roughnessMap:detailed ? surfaces[finish+"Finish"] : null
    roughnessChannel:Material.G
    occlusionMap:roughnessMap
    occlusionChannel:Material.R
    occlusionAmount:.67
    clearcoatAmount:detailed ? ({steel:.40,wing:.19,horn:.21,bone:.34,wood:.12,ice:.86})[finish] ?? 0 : 0
    clearcoatRoughnessAmount:finish==="ice" ? .12 : finish==="bone" ? .21 : .29
}

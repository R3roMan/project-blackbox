import QtQuick3D

PrincipledMaterial {
    id: material
    property bool textured: false
    property string pattern: ""
    readonly property string texturePath: textured && pattern
        ? "../assets/surfaces/pets/" + pattern : ""

    baseColorMap: texturePath ? colorTexture : null
    normalMap: texturePath ? normalTexture : null
    roughnessMap: texturePath ? finishTexture : null
    roughnessChannel: Material.G
    occlusionMap: roughnessMap
    occlusionChannel: Material.R
    occlusionAmount: .64

    component SurfaceTexture: Texture {
        generateMipmaps: true
        minFilter: Texture.Linear
        magFilter: Texture.Linear
        mipFilter: Texture.Linear
        tilingModeHorizontal: Texture.Repeat
        tilingModeVertical: Texture.Repeat
    }

    SurfaceTexture { id: colorTexture; source: material.texturePath ? material.texturePath + "-color.webp" : "" }
    SurfaceTexture { id: normalTexture; source: material.texturePath ? material.texturePath + "-normal.webp" : "" }
    SurfaceTexture { id: finishTexture; source: material.texturePath ? material.texturePath + "-surface.webp" : "" }
}

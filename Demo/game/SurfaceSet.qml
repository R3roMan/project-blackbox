import QtQuick3D

Node {
    id: surfaces
    required property bool detailed
    property bool organic:true
    property bool industrial:true
    property bool woven:true
    property bool bone:organic
    property bool timber:false

    property alias hideNormal:hideN
    property alias hideFinish:hideR
    property alias steelNormal:steelN
    property alias steelFinish:steelR
    property alias weaveNormal:weaveN
    property alias weaveFinish:weaveR
    property alias wingNormal:wingN
    property alias wingFinish:wingR
    property alias wingColor:wingC
    property alias hornNormal:hornN
    property alias hornFinish:hornR
    property alias hornColor:hornC
    property alias boneNormal:boneN
    property alias boneFinish:boneR
    property alias woodNormal:woodN
    property alias woodFinish:woodR
    property alias woodColor:woodC
    property alias lightProbe:studio

    component Map: Texture {
        generateMipmaps:true
        minFilter:Texture.Linear
        magFilter:Texture.Linear
        mipFilter:Texture.Linear
        tilingModeHorizontal:Texture.Repeat
        tilingModeVertical:Texture.Repeat
    }

    Map {id:hideN;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/hide-normal.webp" : ""}
    Map {id:hideR;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/hide-surface.webp" : ""}
    Map {id:steelN;source:surfaces.detailed && surfaces.industrial ? "../assets/surfaces/steel-normal.webp" : ""}
    Map {id:steelR;source:surfaces.detailed && surfaces.industrial ? "../assets/surfaces/steel-surface.webp" : ""}
    Map {id:weaveN;source:surfaces.detailed && surfaces.woven ? "../assets/surfaces/weave-normal.webp" : ""}
    Map {id:weaveR;source:surfaces.detailed && surfaces.woven ? "../assets/surfaces/weave-surface.webp" : ""}
    Map {id:wingN;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/wing-normal.webp" : ""}
    Map {id:wingR;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/wing-surface.webp" : ""}
    Map {id:wingC;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/wing-color.webp" : ""}
    Map {id:hornN;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/horn-normal.webp" : ""}
    Map {id:hornR;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/horn-surface.webp" : ""}
    Map {id:hornC;source:surfaces.detailed && surfaces.organic ? "../assets/surfaces/horn-color.webp" : ""}
    Map {id:boneN;source:surfaces.detailed && surfaces.bone ? "../assets/surfaces/bone-normal.webp" : ""}
    Map {id:boneR;source:surfaces.detailed && surfaces.bone ? "../assets/surfaces/bone-surface.webp" : ""}
    Map {id:woodN;source:surfaces.detailed && surfaces.timber ? "../assets/surfaces/wood-normal.webp" : ""}
    Map {id:woodR;source:surfaces.detailed && surfaces.timber ? "../assets/surfaces/wood-surface.webp" : ""}
    Map {id:woodC;source:surfaces.detailed && surfaces.timber ? "../assets/surfaces/wood-color.webp" : ""}
    Texture {id:studio;source:surfaces.detailed ? "../assets/surfaces/sky-light.hdr" : ""}
}

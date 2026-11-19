import QtQuick3D

Node {
    id: surfaces
    required property bool detailed
    property bool organic:true
    property bool industrial:true
    property bool woven:true

    property alias hideNormal:hideN
    property alias hideFinish:hideR
    property alias steelNormal:steelN
    property alias steelFinish:steelR
    property alias weaveNormal:weaveN
    property alias weaveFinish:weaveR
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
    Texture {id:studio;source:surfaces.detailed ? "../assets/surfaces/sky-light.hdr" : ""}
}

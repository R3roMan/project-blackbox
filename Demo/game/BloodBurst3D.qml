import QtQuick
import QtQuick3D

Node {
    id:burst
    required property var event
    required property int revision
    property bool motion:true
    readonly property real age:{revision;return motion ? 1-event.life/event.span : .37}
    readonly property real spread:event.size*(event.boss ? 1.7 : 1.02)
    position:Qt.vector3d(event.lane,event.elevation,-event.depth)
    opacity:Math.pow(Math.max(0,1-age),.64)
    PrincipledMaterial {
        id:blood
        baseColor:burst.event.dark ? "#24152c" : "#780e26"
        roughness:.34
        specularAmount:.7
        clearcoatAmount:.49
        clearcoatRoughnessAmount:.25
    }
    PrincipledMaterial {
        id:moist
        baseColor:burst.event.dark ? "#39204d" : "#9b263b"
        roughness:.30
        specularAmount:.66
    }
    Repeater3D {
        model:burst.event.boss ? 21 : 12
        Model {
            required property int index
            readonly property real angle:index*2.399963+burst.event.id*.376
            readonly property real travel:(burst.age+.03)*(index%6*.34+.4)*burst.spread
            readonly property real size:(.032+(index%4)*.013)*burst.spread
            source:"#Sphere"
            x:Math.cos(angle)*travel*111
            y:Math.sin(angle)*travel*104+burst.age*29-burst.age*burst.age*145*burst.spread
            z:Math.cos(angle*3.17)*travel*55
            eulerRotation.z:Math.sin(angle)*44
            scale:Qt.vector3d(size,size*(1.1+travel*.88),size*.65)
            materials:[index%3===0 ? moist : blood]
            castsShadows:false
        }
    }
}

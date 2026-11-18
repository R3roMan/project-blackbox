import QtQuick
import QtQuick3D

Node {
    id:bubble
    required property int targetId
    required property bool pickable
    required property real clock
    scale:Qt.vector3d(1+Math.sin(clock*3.4+targetId)*.035,1+Math.cos(clock*4.1+targetId)*.035,1)
    Model {
        source:"#Sphere"
        objectName:String(bubble.targetId)
        pickable:bubble.pickable
        scale:Qt.vector3d(1.30,1.30,1.30)
        opacity:.33
        materials:PrincipledMaterial {baseColor:"#79c4e4"; roughness:.10; metalness:.24; alphaMode:PrincipledMaterial.Blend}
    }
    Model {
        source:"#Sphere"
        scale:Qt.vector3d(.91,.91,.91)
        opacity:.15
        materials:PrincipledMaterial {baseColor:"#974dcb"; roughness:.31; metalness:.42}
    }
    Model {
        source:"#Sphere"
        x:-27; y:31; z:46
        scale:Qt.vector3d(.35,.13,.06)
        eulerRotation.z:-34
        materials:PrincipledMaterial {baseColor:"#e6ffff"; lighting:PrincipledMaterial.NoLighting}
    }
    Model {
        source:"#Sphere"
        x:30; y:-28; z:44
        scale:Qt.vector3d(.18,.07,.045)
        eulerRotation.z:-34
        materials:PrincipledMaterial {baseColor:"#7fe9ff"; lighting:PrincipledMaterial.NoLighting}
    }
}

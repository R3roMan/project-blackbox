pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: vampire
    property var surfaces:null
    objectName: "blandromedusRig"
    required property int targetId
    required property real clock
    required property real strike
    required property bool live
    property bool angry:false
    readonly property real eyeSwing:Math.sin(clock*3.3)*7+strike*14
    readonly property real wingBeat:Math.sin(clock*4.2)*21-strike*14

    LitSurface { surfaces:vampire.surfaces; finish:"hide"; id:bone; baseColor:"#eee1ce"; roughness:.67 }
    PrincipledMaterial { id:rib; baseColor:"#ba9e91"; roughness:.76 }
    LitSurface { surfaces:vampire.surfaces; finish:"weave"; id:cloak; baseColor:"#31153e"; roughness:.79; cullMode:Material.NoCulling }
    LitSurface { surfaces:vampire.surfaces; finish:"hide"; id:membrane; baseColor:"#632c94"; roughness:.49; cullMode:Material.NoCulling }
    PrincipledMaterial { id:blood; baseColor:"#96152e"; roughness:.25 }
    PrincipledMaterial { id:cavity; baseColor:"#260e24"; roughness:.82 }
    PrincipledMaterial { id:eye; baseColor:"#ffe5d0"; roughness:.17 }
    PrincipledMaterial {
        id:iris
        baseColor:vampire.angry ? "#ff9b59" : "#f7354f"
        emissiveFactor:Qt.vector3d(.33,.01,.025)
        roughness:.18
    }
    ScallopedWingGeometry {id:wing}
    Repeater3D {
        model:[-1,1]
        Node {
            required property int modelData
            x:modelData*27
            y:10
            z:-19
            scale:Qt.vector3d(modelData,1,1)
            eulerRotation.y:-19+vampire.wingBeat
            Model {geometry:wing; scale:Qt.vector3d(1.16,1.31,1); materials:[membrane]}
            Model {
                geometry:wing
                position:Qt.vector3d(-19,-44,-6)
                eulerRotation.z:-38
                scale:Qt.vector3d(.78,1.26,.9)
                materials:[cloak]
            }
            Model {
                source:"#Sphere"
                position:Qt.vector3d(52,26,-9)
                eulerRotation.z:72
                scale:Qt.vector3d(.079,1.19,.085)
                materials:[rib]
            }
        }
    }
    Model {
        objectName:String(vampire.targetId)
        pickable:vampire.live
        source:"#Sphere"; y:-23
        scale:Qt.vector3d(.65,1.12,.47)
        materials:[cavity]
    }
    Repeater3D {
        model:5
        Node {
            required property int index
            readonly property real ribWidth:.96-index*.105
            y:7-index*12
            z:7
            Model {
                source:"#Sphere"
                scale:Qt.vector3d(parent.ribWidth,.115,.45)
                materials:[bone]
            }
            Model {
                source:"#Sphere"
                y:-7; z:4
                scale:Qt.vector3d(parent.ribWidth*.86,.07,.38)
                materials:[rib]
            }
        }
    }
    // The wet stain sits on one side of the pale moon-shaped mask.
    Model {
        source:"#Sphere"
        objectName:String(vampire.targetId)
        pickable:vampire.live
        y:51; z:15
        scale:Qt.vector3d(1.29,.75,.53)
        materials:[bone]
    }
    Repeater3D {
        model:7
        Model {
            required property int index
            source:"#Sphere"
            x:14+index*5
            y:59-index*4+Math.sin(index*4.2)*9
            z:38-index*2.7
            eulerRotation.z:-23-index*6
            scale:Qt.vector3d(.35,.41-index*.030,.145)
            materials:[blood]
        }
    }
    Model {
        source:"#Sphere"
        y:47; z:39
        scale:Qt.vector3d(.48,.53,.075)
        materials:[blood]
    }
    Model {
        source:"#Sphere"
        y:47; z:43
        scale:Qt.vector3d(.38,.435,.045)
        materials:[cavity]
    }
    Repeater3D {
        model:7
        Model {
            required property int index
            source:"#Sphere"
            x:vampire.eyeSwing*(index/6)
            y:49-index*6.4
            z:44+Math.sin(index*.4)*9
            eulerRotation.z:vampire.eyeSwing*.8
            scale:Qt.vector3d(.080+index*.002,.137,.078)
            materials:[blood]
        }
    }
    Node {
        x:vampire.eyeSwing
        y:6
        z:53+vampire.strike*7
        Model {source:"#Sphere"; scale:Qt.vector3d(.25,.23,.24); materials:[eye]}
        Model {source:"#Sphere"; z:11; scale:Qt.vector3d(.15,.14,.07); materials:[iris]}
        Model {source:"#Sphere"; z:14.4; scale:Qt.vector3d(.052,.115,.036); materials:[cavity]}
        Model {source:"#Sphere"; x:-2.7; y:4.2; z:16; scale:Qt.vector3d(.037,.028,.018); materials:[eye]}
    }
}

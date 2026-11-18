pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id:arms
    required property color skin
    required property real clock
    required property real strike
    PrincipledMaterial {id:flesh; baseColor:arms.skin; roughness:.74}
    PrincipledMaterial {id:knuckle; baseColor:Qt.darker(arms.skin,1.19); roughness:.64}
    PrincipledMaterial {id:nail; baseColor:"#bdaa97"; roughness:.64}

    Repeater3D {
        model:[-1,1]
        Node {
            required property int modelData
            x:48*modelData
            y:15
            z:18
            scale:Qt.vector3d(modelData,1,1)
            eulerRotation.z:modelData*(5+Math.sin(arms.clock*5)*4)
            eulerRotation.x:-Math.max(0,arms.strike)*46+Math.min(0,arms.strike)*20
            Model {source:"#Sphere"; scale:Qt.vector3d(.25,.30,.26); materials:[flesh]}
            Model {
                source:"#Sphere"; x:4; y:-13; eulerRotation.z:11
                scale:Qt.vector3d(.19,.35,.19); materials:[flesh]
            }
            Node {
                x:6; y:-25; z:5
                eulerRotation.x:-19-arms.strike*37
                Model {
                    source:"#Sphere"; y:-8; z:3; eulerRotation.z:-8
                    scale:Qt.vector3d(.151,.29,.17); materials:[knuckle]
                }
                Model {source:"#Sphere"; y:-20; z:7; scale:Qt.vector3d(.187,.15,.15); materials:[flesh]}
                Repeater3D {
                    model:3
                    Model {
                        required property int index
                        source:"#Sphere"; x:(index-1)*5; y:-26+Math.abs(index-1)*1.9; z:9
                        scale:Qt.vector3d(.056,.11,.063); materials:[knuckle]
                    }
                }
                Model {source:"#Sphere"; x:-7; y:-20; z:13; eulerRotation.z:36; scale:Qt.vector3d(.054,.10,.061); materials:[knuckle]}
                Repeater3D {
                    model:3
                    Model {
                        required property int index
                        source:"#Cone"; x:(index-1)*5; y:-29+Math.abs(index-1)*1.8; z:10.7
                        eulerRotation.z:180+(index-1)*7
                        scale:Qt.vector3d(.033,.054,.042); materials:[nail]
                    }
                }
            }
        }
    }
}

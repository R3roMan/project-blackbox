import QtQuick
import QtQuick3D

Node {
    id:ship
    property var surfaces:null
    required property var enemy
    required property var spec
    required property bool live
    required property real strike
    readonly property bool carrier:enemy.type==="mothergalian"
    readonly property bool guard:enemy.type==="fizzalien"
    readonly property bool camouflaged:enemy.type==="veilskate"
    SickleHornGeometry { id:horn }
    LitSurface {
        surfaces:ship.surfaces; finish:"steel"; id:hull; baseColor:ship.spec.skin
        metalness:ship.camouflaged ? .12 : .56; roughness:ship.camouflaged ? .88 : .33
        emissiveFactor:ship.camouflaged ? Qt.vector3d(.042,.061,.065) : Qt.vector3d(0,0,0)
    }
    LitSurface {
        surfaces:ship.surfaces; finish:"steel"; id:armor; baseColor:Qt.darker(ship.spec.skin,2.5)
        metalness:ship.camouflaged ? .12 : .71; roughness:ship.camouflaged ? .86 : .31; cullMode:Material.NoCulling
        emissiveFactor:ship.camouflaged ? Qt.vector3d(.025,.033,.040) : Qt.vector3d(0,0,0)
    }
    LitSurface { surfaces:ship.surfaces; finish:"steel"; id:edge; baseColor:Qt.lighter(ship.spec.skin,1.58); metalness:.66; roughness:.38; cullMode:Material.NoCulling }
    PrincipledMaterial { id:engine; baseColor:ship.spec.accent; lighting:PrincipledMaterial.NoLighting }
    PrincipledMaterial { id:windowGlass; baseColor:"#21162d"; metalness:.37; roughness:.13 }
    PrincipledMaterial { id:mottle; baseColor:"#747c6d"; roughness:.84; emissiveFactor:Qt.vector3d(.14,.15,.11) }
    Model {
        objectName:String(ship.enemy.id); pickable:ship.live
        source:"#Sphere"; scale:Qt.vector3d(ship.carrier ? 1.80 : 1.22,ship.camouflaged ? .38 : .49,ship.camouflaged ? .92 : 1.34); materials:[hull]
    }
    Model {
        objectName:String(ship.enemy.id); pickable:ship.live
        source:"#Sphere"; y:16; z:11; scale:Qt.vector3d(.78,.38,.87); materials:[windowGlass]
    }
    Model {
        source:"#Sphere"; y:14; z:48; scale:Qt.vector3d(.49,.085,.08); materials:[engine]
    }
    Repeater3D {
        model:[-1,1]
        Node {
            required property int modelData
            scale:Qt.vector3d(modelData,1,1)
            Model {
                objectName:String(ship.enemy.id); pickable:ship.live
                source:"#Cone"; x:51; y:-4; z:-17; eulerRotation:Qt.vector3d(-90,0,0)
                scale:Qt.vector3d(ship.carrier ? 1.46 : 1.10,.97,.19); materials:[armor]
            }
            Model {
                source:"#Cube"; x:46; y:7; z:19; eulerRotation.y:-23
                scale:Qt.vector3d(.13,.10,.59); materials:[edge]
            }
            Repeater3D {
                model: ship.camouflaged ? 4 : 0
                Model {
                    required property int index
                    source:"#Sphere"
                    x: 18+index*14
                    y: 3-index*2
                    z: 45-index*8
                    scale:Qt.vector3d(.29,.090,.055)
                    eulerRotation.z:-24+index*17
                    materials:index%2 ? [armor] : [mottle]
                }
            }
            Model {
                geometry:horn; x:ship.carrier ? 57 : 38; y:12; z:1
                eulerRotation:Qt.vector3d(-25,36,-18)
                scale:Qt.vector3d(.56,ship.guard ? .80 : .65,.55)
                materials:[edge]
            }
            Model {
                source:"#Cylinder"; x:ship.carrier ? 64 : 45; y:-9; z:14-ship.strike*12
                eulerRotation.x:90; scale:Qt.vector3d(.17,.57,.16); materials:[armor]
            }
            Model {
                source:"#Sphere"; x:ship.carrier ? 64 : 45; y:-9; z:42-ship.strike*9
                scale:Qt.vector3d(.092,.082,.041); materials:[engine]
            }
        }
    }
}

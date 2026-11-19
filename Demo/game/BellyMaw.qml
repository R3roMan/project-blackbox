pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id:maw
    required property color hide
    required property real clock
    required property real bite
    property int style:0
    property bool simplified:false
    property var surfaces:null
    objectName:"bellyMaw"
    readonly property real wide:style===2 ? 44 : style===1 ? 42 : 43
    readonly property real tall:(style===2 ? 27 : style===1 ? 39 : 34)+bite*12
    readonly property real flex:Math.sin(clock*6.1)*.66
    readonly property int teeth:simplified ? 11 : style===1 ? 27 : 23

    LitSurface {
        id:gum
        surfaces:maw.surfaces; finish:"bone"
        normalStrength:.23
        baseColor:maw.style===1 ? "#693244" : maw.style===2 ? "#803b53" : Qt.darker(maw.hide,1.39)
        metalness:.05
        roughness:.28
    }
    PrincipledMaterial {id:throat; baseColor:"#1a0714"; lighting:PrincipledMaterial.NoLighting}
    LitSurface {surfaces:maw.surfaces; finish:"bone"; id:enamel; baseColor:"#efd3a8"; roughness:.47}
    LitSurface {surfaces:maw.surfaces; id:lip; baseColor:maw.style===1 ? "#c26868" : Qt.lighter(maw.hide,1.30); roughness:.58}
    LitSurface {surfaces:maw.surfaces; finish:"bone"; id:tongue; baseColor:maw.style===1 ? "#a73e79" : "#df586b"; roughness:.35}
    LitSurface {surfaces:maw.surfaces; finish:"bone"; id:crease; baseColor:"#8f294b"; roughness:.40}

    Model {
        source:"#Sphere"
        scale:Qt.vector3d((maw.wide+6)*.02,(maw.tall+6)*.02,.25)
        materials:[gum]
    }
    Model {
        source:"#Sphere"
        z:9
        scale:Qt.vector3d(maw.wide*.0205,maw.tall*.0205,.077)
        materials:[throat]
    }

    Repeater3D {
        model:maw.style===1 ? 9 : 0
        Model {
            required property int index
            readonly property real phase:index*Math.PI*2/9+maw.clock*.1
            source:"#Sphere"
            position:Qt.vector3d(Math.cos(phase)*(maw.wide+3),Math.sin(phase)*(maw.tall+3),3)
            eulerRotation.z:phase*180/Math.PI-90
            scale:Qt.vector3d(.065,.20,.065)
            materials:[lip]
        }
    }
    Repeater3D {
        model:maw.style===2 ? [-1,1] : []
        Model {
            required property int modelData
            source:"#Sphere"
            y:modelData*(maw.tall+6)
            z:6
            scale:Qt.vector3d(.87,.07,.12)
            materials:[lip]
        }
    }
    Repeater3D {
        model:maw.teeth
        Model {
            required property int index
            readonly property real phase:index*Math.PI*2/maw.teeth
            readonly property real inset:index%2 ? 2.9 : 4.9
            source:"#Cone"
            x:(maw.wide-inset)*Math.cos(phase)
            y:(maw.tall-inset)*Math.sin(phase)
            z:10+index%2*2.7
            eulerRotation.z:phase*180/Math.PI+90
            scale:Qt.vector3d(.060,index%3 ? .073 : .096,.072)
            materials:[enamel]
        }
    }

    // Tongue root and two fleshy joints are kept inside the bite ring.
    Node {
        x:maw.flex*(7+maw.bite*6)
        y:-maw.tall*.48+maw.bite*8
        z:13+maw.bite*6
        eulerRotation.z:maw.flex*(18+maw.bite*17)
        Model {
            source:"#Sphere"; y:3
            eulerRotation.x:-24
            scale:Qt.vector3d(maw.style===2 ? .22 : .26,.32+maw.bite*.11,.11)
            materials:[tongue]
        }
        Model {
            source:"#Sphere"; y:10; z:2
            scale:Qt.vector3d(.022,.17,.035)
            materials:[crease]
        }
        Repeater3D {
            model:maw.style===2 ? [-1,1] : [0]
            Model {
                required property int modelData
                source:"#Sphere"
                x:modelData*7
                y:15+maw.bite*7
                z:3+maw.bite*4
                eulerRotation.z:-modelData*(23+maw.flex*12)
                scale:Qt.vector3d(maw.style===2 ? .108 : .19,.155+maw.bite*.10,.084)
                materials:[tongue]
            }
        }
    }
}

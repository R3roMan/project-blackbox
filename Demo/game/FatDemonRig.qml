import QtQuick
import QtQuick3D

Node {
    id:rig
    property Material iceMaterial:null
    property var surfaces:null
    objectName:"fatDemonRig"
    visible:teacher || enemy.type==="papapoganus"
    required property var enemy
    required property int revision
    property bool live:true
    readonly property bool teacher:enemy.type === "oblogabgalus"
    property real molt:0
    property real windup:0
    readonly property real clock:{revision;return enemy.age}
    readonly property bool spraying:{revision;return enemy.sprayLeft>0 || molt>0 && molt<1}
    readonly property bool angry:{revision;return enemy.anger || enemy.hurtFace>0}
    scale:Qt.vector3d(1-molt*.35,1-molt*.28,1-molt*.30)
    LitSurface { surfaces:rig.surfaces; finish:"hide"; id:flesh; baseColor:rig.teacher ? (rig.angry ? "#cf992e" : "#c3b257") : (rig.angry ? "#86746d" : "#777579"); roughness:.93}
    LitSurface { surfaces:rig.surfaces; finish:"hide"; id:fold; baseColor:rig.teacher ? "#7b6537" : "#36323c"; roughness:1}
    PrincipledMaterial {id:eye; baseColor:"#e9ce69"; roughness:.34}
    PrincipledMaterial {id:black; baseColor:"#140d17"; lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id:wet; baseColor:rig.teacher ? "#8eb62a" : "#ebce29"; roughness:.12; metalness:.1}
    Model {objectName:String(rig.enemy.id);pickable:rig.live;source:"#Sphere";scale:Qt.vector3d(1.62,1.48,1.10);materials:rig.iceMaterial ? [rig.iceMaterial] : ([flesh])}
    Repeater3D {
        model:rig.teacher ? 11 : 17
        Model {
            required property int index
            readonly property real theta:index*2.39996
            source:"#Sphere"
            position:Qt.vector3d(Math.cos(theta)*61,Math.sin(theta)*55,43+Math.cos(theta)*9)
            scale:rig.teacher ? Qt.vector3d(.70,.044,.047) : Qt.vector3d(.18,.12,.022)
            eulerRotation.z:rig.teacher ? Math.sin(theta)*14 : 0
            materials:rig.iceMaterial ? [rig.iceMaterial] : ([fold])
        }
    }
    Repeater3D {
        model:3
        Model {required property int index;source:"#Sphere";position:Qt.vector3d(0,22-index*15,46+index*6);scale:Qt.vector3d(.74-index*.10,.19,.32);materials:rig.iceMaterial ? [rig.iceMaterial] : ([flesh])}
    }
    Node {
        y:48;z:47
        Repeater3D {
            model:[-1,1]
            Node {
                required property int modelData
                x:modelData*(rig.teacher ? 17 : 28)
                y:rig.angry ? -3 : 0
                Model { objectName:"eye:"+rig.enemy.id; pickable:rig.live;source:"#Sphere";scale:Qt.vector3d(rig.teacher ? .095 : .24,.12,.12);materials:rig.iceMaterial ? [rig.iceMaterial] : ([eye])}
                Model { objectName:"eye:"+rig.enemy.id; pickable:rig.live;source:"#Sphere";z:6;x:Math.sin(rig.clock)*1.5;scale:Qt.vector3d(.046,.09,.035);materials:rig.iceMaterial ? [rig.iceMaterial] : ([black])}
                Model {source:"#Cube";y:8;z:5;eulerRotation.z:modelData*(rig.angry ? 24 : -14);scale:Qt.vector3d(.26,.034,.05);materials:rig.iceMaterial ? [rig.iceMaterial] : ([fold])}
            }
        }
        Model {source:"#Sphere";y:-20-rig.windup*4;z:7;scale:Qt.vector3d(.52,rig.spraying ? .37 : .065+rig.windup*.29,.05);materials:rig.iceMaterial ? [rig.iceMaterial] : ([black])}
    }
    Repeater3D {
        model:rig.spraying ? 19 : 0
        Model {
            required property int index
            readonly property real progress:((rig.clock*1.5+index/19)%1)
            source:"#Sphere"
            x:Math.sin(rig.clock*2.9+index*.42)*progress*110
            y:(rig.teacher ? 24 : -5)+Math.sin(progress*3.14)*55-progress*100
            z:58+progress*330
            scale:Qt.vector3d(.07+progress*.10,.12+progress*.15,.10)
            materials:rig.iceMaterial ? [rig.iceMaterial] : ([wet])
        }
    }
}

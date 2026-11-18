import QtQuick
import QtQuick3D

View3D {
    id: view
    objectName:"sunOrb3D"
    required property real turn
    required property color shade
    explicitTextureWidth: Math.max(40,Math.min(350,Math.round(width*Screen.devicePixelRatio)))
    explicitTextureHeight: explicitTextureWidth
    camera: eye
    environment: SceneEnvironment { backgroundMode: SceneEnvironment.Transparent; antialiasingMode: SceneEnvironment.MSAA }
    OrthographicCamera {
        id:eye
        z:200
        horizontalMagnification:Math.max(.01,view.width/240)
        verticalMagnification:horizontalMagnification
    }
    DirectionalLight {eulerRotation:Qt.vector3d(-24,-24,-14);brightness:2.6;color:"#fff2ce";ambientColor:"#ffa87d"}
    Node {
        eulerRotation:Qt.vector3d(-16,view.turn,11)
        Model {
            source:"#Sphere"
            scale:Qt.vector3d(.92,.92,.92)
            materials:PrincipledMaterial {
                baseColor:view.shade
                emissiveFactor:Qt.vector3d(.85,.60,.29)
                roughness:.95
            }
        }
        Repeater3D {
            model:17
            Model {
                required property int index
                readonly property real a:index*2.39996
                readonly property real yUnit:.85-index*.102
                readonly property real ring:Math.sqrt(Math.max(0,1-yUnit*yUnit))*45.2
                source:"#Sphere"
                x:Math.cos(a)*ring;y:yUnit*45.2;z:Math.sin(a)*ring
                eulerRotation:Qt.vector3d(a*57,0,index*27)
                scale:Qt.vector3d(.042+(index%3)*.016,.029,.018)
                materials:PrincipledMaterial {baseColor:"#ffc17b";lighting:PrincipledMaterial.NoLighting}
            }
        }
    }
}

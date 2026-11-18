pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: burst
    required property var effect
    required property int revision
    required property real aspect
    property bool motion:true
    property int detail:1
    readonly property real time: {revision;return Math.max(0,1-effect.life/effect.span)}
    readonly property real phase:motion ? time : .35
    readonly property real opacityScale:Math.min(1,(1-time)*1.75)
    readonly property string kind:effect.kind
    readonly property bool crystal:kind==="freeze"
    readonly property bool lightning:kind==="electric" || kind==="intercept"
    readonly property bool molten:kind==="burn" || kind==="explosive"
    readonly property bool droplets:["poison","sticky","blood"].includes(kind)
    readonly property bool bullets:kind==="reload" || kind==="coin"
    readonly property bool protection:kind==="guard"
    readonly property color pigment:effect.color
    readonly property int count:detail===2 ? 7 : 5
    readonly property var points:{
        if (effect.points?.length) return effect.points.slice(0,detail===2 ? 4 : 3)
        const depth=effect.anchor==="self" ? 315 : 885
        return [{lane:(effect.x-.5)*depth*aspect*1.064,elevation:(.5-effect.y)*depth*1.064,depth:depth}]
    }
    opacity:opacityScale
    PrincipledMaterial {id:lit; baseColor:burst.pigment; lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id:flared; baseColor:Qt.lighter(burst.pigment,1.45); lighting:PrincipledMaterial.NoLighting}
    PrincipledMaterial {id:mist; baseColor:Qt.rgba(burst.pigment.r,burst.pigment.g,burst.pigment.b,.33); alphaMode:PrincipledMaterial.Blend; lighting:PrincipledMaterial.NoLighting; cullMode:Material.NoCulling}
    Repeater3D {
        model:burst.points
        Node {
            id: spark
            required property var modelData
            x:modelData.lane; y:modelData.elevation; z:-modelData.depth+20
            readonly property real reach:(burst.effect.anchor==="self" ? 34 : 72)*(1+burst.phase*.82)+burst.effect.power*6
            eulerRotation.z:burst.phase*(burst.kind==="cut" ? 96 : 29)
            Loader3D {
                active:burst.protection
                sourceComponent:Node {
                    Model {
                        source:"#Cube";y:burst.phase*41;z:15
                        eulerRotation.z:45+burst.phase*12
                        scale:Qt.vector3d(.59+burst.phase*.26,.59+burst.phase*.26,.062)
                        materials:[mist]
                    }
                    Model {
                        source:"#Cube";y:burst.phase*40+32;z:19;eulerRotation.z:-43
                        scale:Qt.vector3d(.42,.019,.022);materials:[lit]
                    }
                }
            }
            Repeater3D {
                model:burst.protection ? 0 : burst.count
                Node {
                    id:ray
                    required property int index
                    readonly property real turn:index*2*Math.PI/burst.count+burst.phase*.43
                    eulerRotation.z:turn*180/Math.PI
                    Model {
                        source:burst.crystal || burst.molten ? "#Cone" : burst.droplets ? "#Sphere"
                            : burst.bullets ? "#Cylinder" : "#Cube"
                        x:spark.reach*(burst.droplets ? .56 : .78)
                        y:burst.molten ? burst.phase*19 : burst.lightning ? Math.sin(ray.index*9+burst.phase*17)*8 : 0
                        z:Math.sin(ray.index*4.1)*26
                        eulerRotation.z:burst.molten ? -54+burst.phase*38 : burst.lightning ? 77 : -89
                        eulerRotation.x:burst.bullets ? 68 : 0
                        scale:burst.crystal ? Qt.vector3d(.095,spark.reach*.0068,.12)
                            : burst.molten ? Qt.vector3d(.06+burst.phase*.05,.66*(1-burst.phase*.42),.11)
                            : burst.lightning ? Qt.vector3d(.035,.44,.033)
                            : burst.droplets ? Qt.vector3d(.13,.075,.14)
                            : burst.bullets ? Qt.vector3d(.068,.22,.072)
                            : Qt.vector3d(.27,.043,.060)
                        materials:[ray.index%3===1 ? flared : lit]
                    }
                    Model {
                        visible:burst.lightning
                        source:"#Cube";x:spark.reach*.59;y:-8;z:11
                        eulerRotation.z:22+burst.phase*34
                        scale:Qt.vector3d(.27,.025,.026);materials:[flared]
                    }
                }
            }
            Model {
                visible:burst.kind==="summon" || burst.kind==="void" || burst.kind==="explosive"
                source:"#Sphere"
                scale:Qt.vector3d(spark.reach*.014,spark.reach*.014,spark.reach*.003)
                materials:[mist]
            }
        }
    }
}

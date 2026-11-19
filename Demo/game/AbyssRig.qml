pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D
import "Rules.js" as Rules

Node {
    id: beast
    property var surfaces:null
    required property var enemy
    required property int revision
    required property bool animate
    required property bool live
    required property real tell
    property bool grabbing: false
    readonly property string kind: enemy.type
    readonly property var spec: Rules.enemyTypes[kind]
    readonly property bool leviathan: !!spec.leviathan
    readonly property bool eel: kind === "faeel"
    readonly property bool fish: ["lantis","crawler","faeel","reapfast"].includes(kind)
    readonly property bool crystal: kind === "nightosphere"
    readonly property bool ink: kind === "shadow"
    readonly property bool illusion:kind === "hallucination"
    readonly property bool reduced:enemy.depth>1700
    readonly property bool doll: kind === "lalaBubu"
    readonly property bool skull: kind === "skorochiyus"
    readonly property bool reaper: kind === "fearme"
    readonly property bool harvester: kind === "harvester"
    readonly property bool crufix:kind === "crufixicatus"
    readonly property bool halfAngel:kind === "archfellanus"
    eulerRotation.z: crufix ? 180 : 0
    readonly property bool furious: { revision; return leviathan && enemy.hp <= enemy.maxHp*.5 }
    readonly property real clock: { revision; return animate ? enemy.age : 0 }
    readonly property bool flash: { revision; return enemy.flash > 0 }
    readonly property real hurtFace: {revision; return (enemy.hurtFace || 0)/.38}
    readonly property bool lamp: { revision; return Rules.lureActive(enemy) }
    readonly property bool mirror: { revision; return Rules.mirrorActive(enemy) }
    readonly property int eyes: { revision; return enemy.eyeCount || 0 }
    readonly property var special: { revision; return enemy.special }
    readonly property real jaw: leviathan && special ? Math.min(1,.22+special.time / Math.max(.1,special.warning)*.65)
        : grabbing ? .89 : Math.min(1,tell*.86+flash*.15)

    LitSurface { surfaces:beast.surfaces; finish:"hide"; id:skin
        baseColor: beast.flash ? Qt.lighter(beast.spec.skin,1.36) : beast.spec.skin
        roughness: beast.fish ? .46 : .78
        metalness: beast.crystal ? .69 : .12
    }
    LitSurface { surfaces:beast.surfaces; finish:"hide"; id:voidSkin; baseColor: "#100915"; roughness: .68 }
    LitSurface {
        surfaces:beast.surfaces; finish:"bone"; id:pale
        baseColor:beast.skull ? "#e1cbb1" : "#d6c0ab"
        roughness:beast.skull ? .30 : .52
        specularAmount:beast.skull ? .82 : .55
    }
    PrincipledMaterial { id: glow; baseColor: beast.spec.accent; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: blue; baseColor: "#54bfe8"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: gold; baseColor: "#f3dd83"; roughness: .28; metalness: .63 }
    PrincipledMaterial { id: pupil; baseColor: "#04010b"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: red; baseColor: "#ff324e"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: flame; baseColor: "#ff7839"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: flameCore; baseColor: "#ffe270"; lighting: PrincipledMaterial.NoLighting }

    Model {
        objectName: String(beast.enemy.id)
        visible:!beast.crystal
        pickable: beast.live && visible
        source: "#Sphere"
        y: beast.kind === "endme" ? -28 : beast.skull ? 22 : 0
        scale: beast.leviathan ? Qt.vector3d(2.70,1.27,1.95)
            : beast.kind === "endme" ? Qt.vector3d(.48,2.05,.40)
            : beast.reaper ? Qt.vector3d(.62,1.5,.72)
            : beast.harvester ? Qt.vector3d(1.80,1.75,1.17)
            : beast.crufix ? Qt.vector3d(.25,1.40,.31)
            : beast.skull ? Qt.vector3d(1.25,.99,.91)
            : beast.kind === "lantis" ? Qt.vector3d(1.51,1.30,1.08)
            : beast.kind === "hallucination" ? Qt.vector3d(.69+beast.enemy.illusionForm*.11,.93+(beast.enemy.illusionForm%3)*.3,.71)
            : Qt.vector3d(1.06,.83,.97)
        opacity: beast.leviathan ? .60 : beast.ink ? .82 : 1
        materials: [beast.skull ? pale : skin]
    }

    Loader3D {
        active:beast.crystal
        sourceComponent:Node {
            AmethystGeometry {id:facets}
            PrincipledMaterial {
                id:glass
                baseColor:"#8a8e53ba"
                roughness:.13
                metalness:.27
                emissiveFactor:Qt.vector3d(.115,.031,.2)
                alphaMode:PrincipledMaterial.Blend
                cullMode:Material.NoCulling
            }
            PrincipledMaterial {
                id:heart
                baseColor:"#d78aff"
                roughness:.16
                emissiveFactor:Qt.vector3d(.78,.32,1)
            }
            Model {
                geometry:facets
                objectName:String(beast.enemy.id)
                pickable:beast.live
                eulerRotation:Qt.vector3d(13+beast.clock*8,beast.clock*29,19)
                materials:[glass]
            }
            Model {
                geometry:facets
                eulerRotation:Qt.vector3d(46-beast.clock*53,28-beast.clock*63,-beast.clock*28)
                scale:Qt.vector3d(.49,.55,.49)
                materials:[heart]
            }
        }
    }

    Repeater3D {
        model: beast.leviathan ? 13 : beast.eel ? beast.reduced ? 5 : 10 : beast.kind === "crawler" ? beast.reduced ? 3 : 5 : 0
        delegate: Node {
            id: coil
            required property int index
            readonly property real taper: Math.max(.18,1-index*(beast.leviathan ? .055 : .075))
            x: (beast.leviathan ? 35 : 21)*index + Math.sin(beast.clock*3-index*.60)*index*5
            y: -index*12 + Math.sin(beast.clock*3-index*.45)*(beast.leviathan ? 30 : 14)
            z: -47-index*(beast.leviathan ? 47 : 29)
            eulerRotation.y: -36+Math.sin(beast.clock*2-index*.5)*21
            Model {
                source: "#Sphere"
                scale: Qt.vector3d(coil.taper*(beast.leviathan ? 1.42 : .76),coil.taper*(beast.leviathan ? .98 : .57),coil.taper*(beast.leviathan ? 1.47 : .95))
                opacity: beast.leviathan ? .50 : 1
                materials: [skin]
            }
            Model {
                source: "#Sphere"
                y: coil.taper*32
                scale: Qt.vector3d(coil.taper*.54,coil.taper*.077,.64)
                materials: [beast.leviathan ? blue : beast.eel ? glow : pale]
                opacity: beast.leviathan ? .72 : .65
            }
            Model {
                source: "#Cone"
                x: coil.taper*27
                y: coil.taper*47
                eulerRotation.z: -27
                scale: Qt.vector3d(.15,coil.taper*.67,.13)
                opacity: .70
                materials: [beast.eel ? glow : skin]
            }
        }
    }

    Node {
        id: maw
        visible: beast.fish || beast.doll || beast.skull
        z: beast.leviathan ? 88 : 45
        y: beast.leviathan ? -8 : beast.skull ? -27 : -5
        readonly property real breadth: beast.leviathan ? 1.82 : beast.kind === "lantis" ? 1.22 : .89
        readonly property real gape: (beast.skull ? 17 : 14)+beast.jaw*(beast.leviathan ? 70 : beast.eel ? 54 : 34)
        Model {
            source:"#Sphere"
            scale:Qt.vector3d(maw.breadth,.27+beast.jaw*.99,.32)
            materials:[voidSkin]
        }
        Repeater3D {
            model: 2
            delegate: Node {
                id: jawRow
                required property int index
                readonly property int side: index ? -1 : 1
                y: side*maw.gape*.47
                z: 8
                eulerRotation.x: side*beast.jaw*37
                Model { source:"#Sphere"; y:jawRow.side*8; scale:Qt.vector3d(maw.breadth,beast.skull ? .12 : .23,beast.skull ? .26 : .58); materials:[beast.skull ? pale : skin]; opacity:beast.leviathan ? .80 : 1 }
                Repeater3D {
                    model: beast.skull ? 0 : beast.leviathan ? 16 : beast.eel ? 13 : 9
                    delegate: Model {
                        required property int index
                        readonly property real angle: (index+(beast.leviathan || jawRow.side>0 ? 0 : .49))/(beast.leviathan ? 15 : beast.eel ? 12 : 8.5)*Math.PI
                        visible: !beast.leviathan || jawRow.side < 0 || ![6,8,10].includes(index)
                        source:"#Cone"
                        x: Math.cos(angle)*maw.breadth*49
                        z: Math.sin(angle)*37
                        y: -jawRow.side*5
                        eulerRotation.z: jawRow.side > 0 ? 180 : 0
                        scale: Qt.vector3d(.074, .095+index%3*.027+beast.jaw*.082,.078)
                        materials:[pale]
                    }
                }
            }
        }
        Model {
            visible: beast.skull
            source:"#Cone"
            y:-6; z:12
            scale:Qt.vector3d(.14,.18+beast.jaw*.37,.10)
            materials:[flame]
        }
    }

    Repeater3D {
        model: beast.harvester ? 0 : beast.kind === "endme" ? 8 : beast.crystal ? 0 : 2
        delegate: Node {
            id: eye
            required property int index
            readonly property int side: index%2 ? 1 : -1
            readonly property bool exposed: beast.kind !== "endme" || index < beast.eyes
            readonly property real scaleFactor: beast.leviathan ? 1.28 : beast.doll ? 1.25 : beast.crufix ? .42 : 1
            x: side*(beast.leviathan ? 65 : beast.crufix ? 17 : beast.kind === "endme" ? 12 : 24)
            y: beast.kind === "endme" ? 58-Math.floor(index/2)*21 : beast.leviathan ? 43 : beast.crufix ? 67 : 25
            z: beast.leviathan ? 99 : beast.kind === "endme" ? 23 : beast.crufix ? 28 : 52
            opacity: exposed ? 1 : .1
            eulerRotation.z: beast.leviathan ? eye.side*18 : 0
            Model {
                visible:beast.hurtFace>0
                source:"#Cube"
                y:12*eye.scaleFactor; z:14
                eulerRotation.z:eye.side*(-24-beast.hurtFace*16)
                scale:Qt.vector3d(.45*eye.scaleFactor,.045,.07)
                materials:[voidSkin]
            }
            Model {
                source:"#Sphere"
                scale:Qt.vector3d(.45*eye.scaleFactor,(beast.leviathan ? .23 : .40)*eye.scaleFactor,.16)
                materials:[pupil]
            }
            Model {
                source:"#Sphere"; z:9
                scale:Qt.vector3d((beast.doll ? .125 : .28)*eye.scaleFactor,
                    (beast.leviathan ? .09 : beast.doll ? .14 : .22)*eye.scaleFactor,.075)
                materials:[beast.crufix ? pupil : beast.doll || beast.furious ? red : beast.skull ? flameCore : glow]
            }
            Model {
                visible: beast.leviathan
                source:"#Sphere"
                y: 11
                z: 1
                scale: Qt.vector3d(.70,.15,.21)
                materials:[skin]
            }
            Model {
                visible: beast.furious
                source:"#Cone"
                y:15
                z:13
                eulerRotation.z: eye.side*59
                scale:Qt.vector3d(.12,.40,.11)
                materials:[blue]
            }
        }
    }
    Model {
        visible: beast.harvester
        source:"#Sphere"
        y:57; z:31
        scale:Qt.vector3d(1.01,1.22,.83)
        materials:[voidSkin]
    }
    Model {
        visible:beast.harvester
        objectName:String(beast.enemy.id)
        pickable:beast.live && visible
        source:"#Rectangle"
        y:55; z:78
        scale:Qt.vector3d(.99,1.19,1)
        materials:PrincipledMaterial {
            lighting:PrincipledMaterial.NoLighting
            alphaMode:PrincipledMaterial.Blend
            baseColorMap:Texture {
                sourceItem:HarvesterInk {
                    phase:beast.clock
                    opening:{beast.revision; return beast.enemy.soulChannel ? 1 : beast.tell*.7}
                }
            }
        }
    }
    Repeater3D {
        model:beast.harvester ? 12 : 0
        delegate:Model {
            required property int index
            source:"#Cone"
            x:(index-5.5)*13
            y:-76-index%4*5
            z:Math.sin(index*2.4)*47
            eulerRotation.z:180+(index-5.5)*3
            scale:Qt.vector3d(.26,.52+index%3*.21,.16)
            materials:[index%3 ? skin : voidSkin]
        }
    }
    Node {
        visible:beast.crufix
        Model {source:"#Sphere"; y:63; z:6; scale:Qt.vector3d(.54,.71,.44); materials:[pale]}
        Model {source:"#Sphere"; y:47; z:28; scale:Qt.vector3d(.21,.10+beast.tell*.11,.06); materials:[voidSkin]}
        Repeater3D {
            model:8
            delegate:Model {
                required property int index
                readonly property real side:index%2 ? 1 : -1
                source:"#Sphere"
                x:side*(12-Math.floor(index/2)*1.4)
                y:28-Math.floor(index/2)*12
                z:18
                eulerRotation.z:side*19
                scale:Qt.vector3d(.28,.042,.10)
                materials:[pale]
            }
        }
        Repeater3D {
            model:4
            delegate:Model {
                required property int index
                readonly property real side:index%2 ? 1 : -1
                source:"#Cylinder"
                x:side*(index<2 ? 35 : 11)
                y:index<2 ? -5 : -78
                eulerRotation.z:index<2 ? side*(11+beast.tell*20) : side*7
                scale:Qt.vector3d(.047,index<2 ? .96 : .77,.047)
                materials:[pale]
            }
        }
        Repeater3D {
            model:13
            delegate:Model {
                required property int index
                source:"#Cube"
                x:Math.sin(beast.enemy.id*3.17+index*9.31)*19
                y:44+(index*13)%46
                z:27+Math.sin(index)*2
                eulerRotation.z:(beast.enemy.id*17+index*67)%180
                scale:Qt.vector3d(.009,.073+index%3*.023,.009)
                materials:[pupil]
            }
        }
        Repeater3D {
            model:16
            delegate:Model {
                required property int index
                readonly property real drift:(beast.clock*.85+index*.173)%1
                source:"#Sphere"
                x:(index%2 ? 1 : -1)*15+Math.sin(drift*4+index)*3
                y:65-drift*131
                z:37
                opacity:(1-drift)*.89
                scale:Qt.vector3d(.045,.055+drift*.095,.029)
                materials:[red]
            }
        }
    }
    Repeater3D {
        model:beast.skull ? 2 : 0
        delegate:Model {
            required property int index
            source:"#Sphere"
            x:index ? 5 : -5
            y:10; z:49
            eulerRotation.z:index ? 23 : -23
            scale:Qt.vector3d(.059,.13,.047)
            materials:[pupil]
        }
    }
    Repeater3D {
        model: beast.skull || beast.furious ? 24 : 0
        delegate: Model {
            required property int index
            readonly property real drift: (beast.clock*(.67+index%4*.11)+index*.213)%1
            source: "#Cone"
            x: Math.cos(index*2.399+drift*3.1)*(51+drift*35)
            y: -42+drift*139
            z: 44+Math.sin(index*2.399)*55
            opacity: (1-drift)*.83
            scale: Qt.vector3d(.026+index%4*.014,.12+index%5*.036,.036)
            materials: [beast.furious ? index%3 ? red : blue : index%3 ? flame : flameCore]
        }
    }
    Node {
        visible: beast.reaper
        x: 39
        y: -5
        z: 42
        eulerRotation.z: -23-beast.tell*61+Math.sin(beast.clock*2.3)*6
        Model { source:"#Cylinder"; scale:Qt.vector3d(.07,2.07,.07); materials:[voidSkin] }
        Model { source:"#Sphere"; y:103; x:30; eulerRotation.z:-17; scale:Qt.vector3d(.95,.21,.10); materials:[glow] }
        Model { source:"#Cone"; y:89; x:71; eulerRotation.z:-137; scale:Qt.vector3d(.26,.85,.11); materials:[glow] }
    }

    Repeater3D {
        model: beast.kind === "tenmani" ? 50 : beast.ink || beast.reaper ? beast.reduced ? 15 : 25 : beast.kind === "endme" ? 10 : 0
        delegate: Model {
            required property int index
            readonly property int arm: Math.floor(index/5)
            readonly property int joint: index%5
            readonly property real side: arm%2 ? 1 : -1
            readonly property real reach: beast.grabbing ? 130 : beast.tell*53
            source:"#Sphere"
            x: side*(24+Math.floor(arm/2)*10+joint*(beast.ink ? 6 : 9))
                + Math.sin(beast.clock*4+arm-joint*.7)*(7+joint*4)
            y: -20-joint*(beast.kind === "endme" ? 34 : 17)-arm%3*7+Math.cos(beast.clock*3+arm-joint*.6)*11
            z: 17 + joint*(6+reach*.25)-arm%3*17
            eulerRotation.x: -reach*.54
            eulerRotation.z: side*(32+Math.sin(beast.clock*2+arm+joint)*22)
            scale: Qt.vector3d(.26-joint*.031,.38+reach*.003,.23-joint*.028)
            opacity: beast.ink ? .63 : 1
            materials:[joint%3 ? skin : voidSkin]
        }
    }
    Repeater3D {
        model: beast.crystal ? beast.reduced ? 7 : 15 : beast.kind === "lantis" || beast.eel || beast.kind === "crawler" ? 12 : beast.ink ? 12 : 0
        delegate: Model {
            required property int index
            readonly property real angle: index*2.399963 + beast.clock*(beast.crystal ? .43 : 0)
            readonly property real orbit: beast.crystal ? 72+87*(1-(beast.clock*.86+index*.163)%1) : 60
            source: beast.ink ? "#Sphere" : "#Cone"
            position:Qt.vector3d(Math.cos(angle)*orbit,Math.sin(angle)*orbit*.66,Math.sin(angle+index*3.1)*orbit)
            eulerRotation:Qt.vector3d(index*53,index*28,-index*69)
            scale: beast.crystal ? Qt.vector3d(.055,.19,.079) : Qt.vector3d(.13,.31+index%4*.059,.12)
            opacity: beast.crystal || beast.ink ? .58 : 1
            materials:[index%5 ? (beast.crystal || beast.ink ? voidSkin : skin) : glow]
        }
    }

    Model {
        visible: beast.kind === "lantis"
        source:"#Cylinder"; x:15; y:65; z:64; eulerRotation.z:-32
        scale:Qt.vector3d(.065,.66,.065); materials:[skin]
    }
    Model {
        visible: beast.kind === "lantis"
        source:"#Sphere"; x:32; y:91; z:77
        scale:Qt.vector3d(.25,.25,.25); materials:[beast.lamp ? glow : voidSkin]
    }
    PointLight { visible:beast.lamp; brightness:beast.lamp ? 5.7 : 0; color:"#ffbd65"; x:32; y:85; z:80; quadraticFade:.38 }

    Model {
        visible: beast.kind === "shadow"
        source:"#Cube"; x:42+beast.tell*34; y:-19; z:53+beast.tell*32
        eulerRotation.z: -47+beast.tell*137
        scale:Qt.vector3d(.085,1.02,.075); materials:[glow]
    }
    Model {
        visible: beast.halfAngel
        source:"#Cone"; y:-24; z:-27; eulerRotation.z:169+Math.sin(beast.clock*4)*13
        scale:Qt.vector3d(1.51,1.75,.31); materials:[voidSkin]
    }
    Loader3D {
        active:beast.halfAngel
        sourceComponent:Node {
            SickleHornGeometry {id:horn; textured:!!beast.surfaces?.detailed}
            LitSurface {id:keratin; surfaces:beast.surfaces; finish:"horn"; baseColor:beast.spec.skin; roughness:.57}
            Repeater3D {
                model:[-1,1]
                Model {
                    required property int modelData
                    geometry:horn
                    x:modelData*24; y:23; z:19
                    scale:Qt.vector3d(modelData*.61,.70,.67)
                    materials:[keratin]
                }
            }
            Repeater3D {
                model:20
                Model {
                    required property int index
                    readonly property real angle:index*Math.PI/10
                    source:"#Sphere"
                    x:Math.cos(angle)*44; y:81+Math.sin(angle)*16; z:Math.sin(angle)*29
                    scale:Qt.vector3d(.17,.077,.145); materials:[voidSkin]
                }
            }
        }
    }
    Model {
        visible: beast.mirror
        source:"#Sphere"; scale:Qt.vector3d(1.65,1.8,.98); opacity:.22; materials:[gold]
    }
    Repeater3D {
        model: beast.doll ? 8 : 0
        delegate: Model {
            required property int index
            source:index > 5 ? "#Sphere" : "#Cone"
            x:(index%2 ? 1 : -1)*(index > 4 ? 56 : 36)
            y:index > 3 ? 52-index%2*10 : -36-index%2*11
            z:index > 4 ? 9 : -8
            scale:Qt.vector3d(.23,.53,.24)
            eulerRotation.z:(index%2 ? 1 : -1)*(28+beast.tell*45)
            materials:[index%2 ? glow : skin]
        }
    }
}

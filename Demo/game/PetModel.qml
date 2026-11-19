pragma ComponentBehavior: Bound
import QtQuick
import QtQuick3D

Node {
    id: pet
    objectName: "petModel"
    required property var helper
    required property real phase
    required property real strike
    property bool animate: true
    property bool resting: false
    property bool detailed: false
    property real chargeProgress:0
    property real chargedFlash:0
    property real fold:resting ? 1 : 0
    Behavior on fold { enabled:pet.animate; NumberAnimation {duration:430;easing.type:Easing.OutCubic} }
    readonly property bool brain: helper.form === "brain"
    readonly property bool miniShadow: helper.form === "minishade"
    readonly property bool bird:["crow","owl","finch","chicken"].includes(helper.form)
    readonly property bool angry: strike > .04
    readonly property bool fairy: helper.form === "fairy"
    readonly property bool spriteGirl: fairy || helper.form === "chibi"
    opacity: 1-fold*.23

    readonly property bool mechanical: ["wasp", "kite", "ray", "beetle"].includes(helper.form)
    readonly property real flap: animate ? Math.sin(phase * (mechanical ? 24 : 11))*(1-fold) : 0
    readonly property string bodyPattern: {
        if (helper.id === "firefly")
            return "shell"
        if (helper.id === "wyvern")
            return "wyvern"
        return ({
            wasp: "wasp", kite: "drone", ray: "circuit", beetle: "shell",
            bat: "fur", moth: "down", drake: "scales", fox: "fur",
            brain: "cortex", fairy: "cloth", chibi: "cloth", minishade: "ink"
        })[helper.form] || ""
    }

    PetSurface {
        id: body
        textured: pet.detailed
        pattern: pet.bodyPattern
        baseColor: textured ? Qt.lighter(pet.helper.skin, pattern === "ink" ? 1.65
            : pet.helper.form === "beetle" ? 1.41 : pet.mechanical ? 1.22 : 1.08)
            : pet.helper.skin
        roughness: !textured ? .56 : pet.brain || pattern === "ink" ? .43 : pattern === "fur" || pattern === "down" ? .85 : .60
        metalness: !pet.mechanical ? .07 : textured && pattern === "shell" ? .31 : .54
        normalStrength: pattern === "cortex" ? .94 : pattern === "fur" || pattern === "down" ? .34 : .63
        clearcoatAmount: textured && (pattern === "wasp" || pattern === "shell" || pattern === "ink") ? .38 : 0
        clearcoatRoughnessAmount: .33
    }
    PetSurface {
        id: wing
        textured: pet.detailed
        pattern: pet.spriteGirl ? "veil" : pet.bodyPattern
        baseColor: Qt.lighter(pet.helper.skin, textured && pet.mechanical ? 1.57 : 1.39)
        roughness: .69
        metalness: pet.mechanical ? .25 : .04
        normalStrength: pet.brain ? .95 : pattern === "fur" || pattern === "down" ? .32 : .58
    }
    PrincipledMaterial { id: dark; baseColor: "#171928"; roughness: .73 }
    PetSurface {
        id: face
        textured: pet.detailed && pet.spriteGirl
        pattern: "skin"
        baseColor: "#e4b4a3"
        roughness: .84
        normalStrength: .20
    }
    PetSurface {
        id: hair
        textured: pet.detailed && pet.spriteGirl
        pattern: "hair"
        baseColor: pet.fairy ? "#435747" : "#c95291"
        roughness: .65
        normalStrength: .68
    }
    PrincipledMaterial {
        id: glow
        baseColor: pet.angry || pet.chargedFlash>0 ? "#fff290" : pet.helper.accent
        lighting: PrincipledMaterial.NoLighting
    }

    Loader3D {
        active:pet.bird
        sourceComponent:BirdPet {
            helper:pet.helper; phase:pet.phase; strike:pet.strike; animate:pet.animate; resting:pet.resting
            detailed:pet.detailed
        }
    }
    Loader3D {
        active:pet.helper.form==="jacko"
        sourceComponent:JackoModel {
            phase:pet.phase
            strike:pet.strike
            charged:pet.chargedFlash
            fold:pet.fold
            motion:pet.animate
            detailed:pet.detailed
        }
    }
    Loader3D {
        active:!pet.bird && pet.helper.form!=="jacko"
        sourceComponent:Node {
            PetDetails {
                helper:pet.helper
                phase:pet.animate ? pet.phase : 0
                strike:pet.strike
                flap:pet.flap
                fold:pet.fold
                detailed:pet.detailed
                bodyPattern:pet.bodyPattern
            }
            Model {
                visible: !pet.brain && !pet.miniShadow
                source: pet.spriteGirl ? "#Cone" : pet.helper.form === "kite" ? "#Cube" : "#Sphere"
                scale: pet.spriteGirl ? Qt.vector3d(.34,.48,.29) : pet.helper.form === "wasp" ? Qt.vector3d(.32, .26, .58)
                    : pet.helper.form === "ray" ? Qt.vector3d(.69, .14, .45)
                    : pet.helper.form === "beetle" ? Qt.vector3d(.54, .37, .42)
                    : pet.helper.form === "fox" ? Qt.vector3d(.38, .39, .6)
                    : Qt.vector3d(.43, .40, .47)
                materials: [body]
            }
            Model {
                visible: !pet.brain
                source: "#Sphere"
                y: pet.spriteGirl ? 21 : 14
                z: 16
                scale: pet.spriteGirl ? Qt.vector3d(.46,.40,.37) : Qt.vector3d(.27, .27, .25)
                materials: [pet.spriteGirl ? face : wing]
            }
            Repeater3D {
                model: pet.spriteGirl ? 8 : 0
                Model {
                    required property int index
                    readonly property real offset: index - 3.5
                    source: "#Sphere"
                    x: offset * 5.7
                    y: 35 - Math.abs(offset)*2.1
                    z: index === 0 || index === 7 ? 11 : 22
                    eulerRotation.z: offset * 24
                    scale: Qt.vector3d(.12, pet.fairy ? .18 : index === 0 || index === 7 ? .32 : .23, .18)
                    materials: [hair]
                }
            }
            Repeater3D {
                model: pet.spriteGirl || pet.helper.form === "fox" ? 2 : 0
                delegate: Node {
                    id: wingJoint
                    required property int index
                    readonly property int side: index === 0 ? -1 : 1
                    x: side * 12
                    y: 7
                    eulerRotation.z: side*((pet.spriteGirl ? 3 : 10)-pet.fold*48+pet.flap*30)
                    eulerRotation.y: side*pet.fold*32
                    Model {
                        source: pet.spriteGirl ? "#Sphere" : "#Cone"
                        x: wingJoint.side*(pet.spriteGirl ? 20 : 23)
                        z: -6
                        eulerRotation.z:wingJoint.side*(pet.spriteGirl ? -13 : -90)
                        scale:pet.spriteGirl ? Qt.vector3d(.50, .13, .29) : Qt.vector3d(.34, .59, .20)
                        materials: [wing]
                    }
                    Model {
                        visible:!pet.spriteGirl
                        source: "#Cone"
                        x: wingJoint.side * 27
                        y: -7
                        z: -11
                        eulerRotation.z: wingJoint.side * -116
                        scale: Qt.vector3d(.15, .43, .13)
                        materials: [body]
                    }
                    Repeater3D {
                        model: 3
                        delegate: Model {
                            required property int index
                            source: "#Cone"
                            x: wingJoint.side * (15 + index*6)
                            y: 2.5
                            z: -11 - index*4
                            eulerRotation.x: 92
                            scale: Qt.vector3d(.075,.125+index*.025,.047)
                            materials: [index === 1 ? body : wing]
                        }
                    }
                }
            }
            Repeater3D {
                model: pet.miniShadow ? 12 : 0
                delegate: Model {
                    required property int index
                    readonly property real angle: index*2.39996 + pet.phase
                    readonly property real fall: (index*.19+pet.phase*(pet.angry ? 2.4 : .86))%1
                    source:"#Cone"
                    position:Qt.vector3d(Math.cos(angle)*(7+fall*22),-fall*39,Math.sin(angle)*10-fall*14)
                    eulerRotation.z: Math.sin(angle)*32
                    opacity:.94-fall*.66
                    scale:Qt.vector3d(.15,.51+fall*.09,.12)
                    materials:[index%5 ? body : dark]
                }
            }
            Repeater3D {
                model: 2
                delegate: Node {
                    id: brow
                    required property int index
                    readonly property int side: index ? 1 : -1
                    x: side * 6
                    y: pet.brain ? -1 : pet.spriteGirl ? 20 : 17
                    z: pet.brain ? 29 : pet.spriteGirl ? 33 : 27
                    scale: pet.brain ? Qt.vector3d(.70, .66, 1) : Qt.vector3d(1, 1, 1)
                    Model {
                        source: "#Sphere"
                        scale: Qt.vector3d(.105, .13, .07)
                        materials: [dark]
                    }
                    Model {
                        source: "#Sphere"
                        z: 4
                        scale: Qt.vector3d(pet.angry ? .066 : .050, pet.resting ? .017 : pet.angry ? .048 : .079, .04)
                        materials: [glow]
                    }
                    Model {
                        visible: pet.angry
                        source: "#Cube"
                        y: 4.5; z: 6
                        eulerRotation.z: brow.side * 25
                        scale: Qt.vector3d(.094,.027,.044)
                        materials: [dark]
                    }
                    Model {
                        visible: ["bat", "drake", "fox", "moth"].includes(pet.helper.form)
                        source: "#Cone"
                        y: 12
                        z: -6
                        eulerRotation.z: brow.side * -19
                        scale: pet.helper.form === "moth" ? Qt.vector3d(.043, .25, .04) : Qt.vector3d(.11, .25, .11)
                        materials: [wing]
                    }
                }
            }
            Model {
                visible: !pet.mechanical && !pet.brain && !pet.spriteGirl
                source: "#Cone"
                y: 10
                z: 30
                eulerRotation.x: 90
                scale: Qt.vector3d(.105,.15,.09)
                materials: [dark]
            }
            Model {
                visible: !pet.brain && !pet.spriteGirl
                source: "#Cone"
                y: -4
                z: -24
                eulerRotation.x: -102
                scale: Qt.vector3d(.16, pet.helper.form === "fox" || pet.helper.form === "drake" ? .46 : .32, .12)
                materials: [body]
            }
            Repeater3D {
                model: pet.brain ? 10 : 0
                Model {
                    required property int index
                    source: "#Sphere"
                    x: (index < 5 ? -1 : 1) * (9 + index % 5 * 2)
                    y: 12 + Math.sin(index % 5 * 1.4) * 5
                    z: (index % 5 - 2) * 8
                    eulerRotation.z: (index < 5 ? 1 : -1) * 25
                    scale: Qt.vector3d(.34, .25, .22)
                    materials: [index % 3 === 0 ? body : wing]
                }
            }
            Repeater3D {
                model: pet.brain ? 8 : 0
                Node {
                    id: leg
                    required property int index
                    readonly property int side: index < 4 ? -1 : 1
                    readonly property real step: pet.animate && !pet.resting ? Math.sin(pet.phase * 17 - index * 1.9) : 0
                    x: side * 17
                    z: (index % 4 - 1.5) * 13
                    eulerRotation.y: leg.side * (leg.index % 4 - 1.5) * 18 + step * 13
                    Model {
                        source: "#Cylinder"
                        x: leg.side * 13
                        y: leg.step * 4
                        eulerRotation.z: leg.side * -66
                        scale: Qt.vector3d(.04, .34-pet.fold*.075, .04)
                        materials: [dark]
                    }
                    Model {
                        source: "#Cylinder"
                        x: leg.side * 30
                        y: -10 - leg.step * 4
                        eulerRotation.z: leg.side * 27
                        scale: Qt.vector3d(.031, .32, .031)
                        materials: [wing]
                    }
                }
            }
            Model {
                visible: pet.strike > 0
                source: "#Sphere"
                scale: Qt.vector3d(.09 + pet.strike * .22, .09 + pet.strike * .22, .09 + pet.strike * .22)
                z: 31
                y: 9
                opacity: .4 + pet.strike
                materials: [glow]
            }
        }
    }
    Repeater3D {
        model:pet.chargeProgress>0 || pet.chargedFlash>0 ? 5 : 0
        Model {
            required property int index
            readonly property real theta:index*2*Math.PI/5+(pet.animate ? pet.phase*4.5 : 0)
            readonly property real radius:30+pet.chargeProgress*9+(pet.chargedFlash>0 ? (1-pet.chargedFlash/.72)*38 : 0)
            source:"#Sphere"
            x:Math.cos(theta)*radius
            y:19+Math.sin(theta)*radius*.60
            z:Math.sin(theta)*radius*.45
            scale:Qt.vector3d(.032+pet.chargeProgress*.04,.05,.046)
            opacity:.35+pet.chargeProgress*.56
            materials:[glow]
        }
    }
}

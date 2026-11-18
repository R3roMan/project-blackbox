import QtQuick
import QtQuick3D
import "WeaponArt.js" as Art
import "MeleeArt.js" as Blade

View3D {
    id: view
    objectName: "weaponModel"
    required property var weapon
    required property real shotLife
    required property real reloadRatio
    required property real rotaryAngle
    required property bool motion

    property real charge: 0
    property bool primed: false
    property bool bayonet: false
    property real stab: 0
    property int sequence: 0
    property int detail:1
    property int combo: 0
    property real staffCharge: 0
    property real staffCast:0
    property real clock: 0
    property point aimOffset: Qt.point(0,0)
    readonly property bool handWeapon: !!weapon.melee || !!weapon.throwing || !!weapon.stab
    readonly property bool staff: !!weapon.staff
    readonly property string pattern: weapon.art || weapon.id
    readonly property bool twins: pattern === "twinpistols" || !!weapon.dual
    readonly property var bladeFrame: Blade.frames[pattern] || Blade.frames.katana
    readonly property var bladePose: Blade.pose(pattern, motion ? intensity : 0, motion ? reloadRatio : 0, combo, sequence)
    readonly property var art: Art.design(weapon)
    readonly property real intensity: Math.min(1, shotLife / weapon.afterglow)
    readonly property var pose: Art.pose(art, motion ? intensity : 0, motion ? reloadRatio : 0, rotaryAngle)
    readonly property point muzzle: {
        pose
        width
        height
        aimOffset
        const fallback = Qt.point(width * .5, height * .32)
        if (!view.camera || width <= 0 || height <= 0)
            return fallback
        sequence
        const point = view.mapFrom3DScene((handWeapon ? bladeTip : staff ? runeTip : twins ? twinTip : tip).scenePosition)
        return Number.isFinite(point.x) && Number.isFinite(point.y) && point.y > 0 && point.y < height
            ? Qt.point(point.x, point.y) : fallback
    }

    explicitTextureWidth: Math.max(1, Math.round(Math.min(960, width * Screen.devicePixelRatio)))
    explicitTextureHeight: Math.max(1, Math.round(explicitTextureWidth * height / Math.max(1, width)))
    camera: handWeapon ? handEye : eye
    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Transparent
        antialiasingMode:view.detail > 0 ? SceneEnvironment.MSAA : SceneEnvironment.NoAA
        antialiasingQuality:view.detail === 2 ? SceneEnvironment.High : SceneEnvironment.Medium
    }
    PerspectiveCamera {
        id: eye
        position: Qt.vector3d(-6, 102, 188)
        eulerRotation: Qt.vector3d(-24, -1.7, 0)
        clipNear: 4
        clipFar: 850
        fieldOfView: view.staff ? 60 : view.twins ? 56 : 42 + (view.art.width - 49) * .13
    }
    PerspectiveCamera {
        id: handEye
        z: 820
        clipNear: 5
        clipFar: 1400
        readonly property real halfHeight: Math.max(241,280*view.height/Math.max(1,view.width))
        fieldOfView: 2*Math.atan(halfHeight/z)*180/Math.PI
    }
    DirectionalLight { eulerRotation: Qt.vector3d(-48, -36, -13); color: "#fff0d6"; brightness: 2.1; ambientColor: "#7885a7" }
    DirectionalLight { eulerRotation: Qt.vector3d(13, 118, 12); color: "#a4b9ff"; brightness: 1.43 }
    PrincipledMaterial { id: enamel; baseColor: view.art.shell; roughness: .53; metalness: .61 }
    PrincipledMaterial { id: rim; baseColor: Qt.lighter(view.art.shell, 1.58); roughness: .42; metalness: .60 }
    PrincipledMaterial { id: dark; baseColor: "#222633"; roughness: .72; metalness: .31 }
    PrincipledMaterial { id: cavity; baseColor: "#13151c"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: grip; baseColor: "#30313f"; roughness: .90 }
    PrincipledMaterial { id: signal; baseColor: view.weapon.color; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: hot; baseColor: "#fff1c5"; lighting: PrincipledMaterial.NoLighting }

    Node {
        id: hand
        position: Qt.vector3d(view.bladePose.x,view.bladePose.y,view.bladePose.z)
        eulerRotation: Qt.vector3d(view.bladePose.pitch-view.aimOffset.y*8.5,
            view.bladePose.yaw-view.aimOffset.x*14,view.bladePose.roll+view.aimOffset.x*10)
        scale: Qt.vector3d(view.bladeFrame.scale,view.bladeFrame.scale,view.bladeFrame.scale)
        Node {
            id: bladeTip
            objectName: "heldBladeTip"
            z: view.bladeFrame.tip-view.bladeFrame.centre
        }
        Node {
            objectName: "heldBladeGrip"
            z: 30-view.bladeFrame.centre
        }
        Loader3D {
            active: view.handWeapon
            z: -view.bladeFrame.centre
            sourceComponent: MeleeRig {
                objectName: "heldMeleeRig"
                weaponId: view.pattern
                accent: view.weapon.color
                primed: view.primed
                held: true
                action: view.bladePose.inner
                spin: view.rotaryAngle
                clock: view.motion ? view.clock : 0
                visible: !view.weapon.throwing || view.intensity < .47
            }
        }
    }
    Node {
        position: Qt.vector3d(19, -30 + view.intensity * 8, 68 - view.intensity * 14)
        eulerRotation: Qt.vector3d(68-view.aimOffset.y*7+Math.sin(view.staffCast*Math.PI)*12,24-view.aimOffset.x*12,8-Math.sin(view.staffCast*Math.PI)*10)
        Node { id: runeTip; z: -136 }
        Loader3D {
            active: view.staff
            sourceComponent: StaffRig {
                kind: view.weapon.staff ? view.weapon.staff.kind : ""
                style:view.weapon.staff ? view.weapon.staff.style || "" : ""
                tint: view.weapon.color
                charge: view.staffCharge
                cast: view.staffCast
                clock: view.motion ? view.clock : 0
            }
        }
    }
    Node {
        visible: view.twins
        y: -13
        z: 39
        Node {
            id: twinTip
            x: view.sequence % 2 ? -44 : 44
            y: 18
            z: -82
        }
        Repeater3D {
            model: view.twins ? 2 : 0
            delegate: Node {
                required property int index
                readonly property int side: index ? 1 : -1
                readonly property real recoil: view.sequence % 2 === 1 - index ? view.intensity : 0
                x: side * (79 + view.pose.shellTravel * .21)
                y: 5 + recoil * 6 - view.pose.shellTravel * .47
                z: recoil * 19 - view.stab * 74
                eulerRotation: Qt.vector3d(-10 - recoil * 13-view.aimOffset.y*8.5,-side*13-view.aimOffset.x*14,view.pose.roll*side)
                Model { source:"#Cube"; scale:Qt.vector3d(view.art.width*.0076,.27,view.art.length*.0098); materials:[enamel] }
                Model { source:"#Cube"; y:14; z:-11; scale:Qt.vector3d(.35,.12,.82); materials:[rim] }
                Model {
                    source:"#Cylinder"
                    z:-51; y:7
                    eulerRotation.x:90
                    scale:Qt.vector3d(view.art.bore*.032,view.art.barrel*.0061,view.art.bore*.032)
                    materials:[dark]
                }
                Model {
                    visible:view.weapon.id==="twinSmgs"
                    source:"#Cube";x:11;y:-24;z:34;eulerRotation.x:-13;scale:Qt.vector3d(.19,.70,.29);materials:[dark]
                }
                Model {
                    visible:view.weapon.id==="twinShotguns"
                    source:"#Cylinder";y:-10;z:-30;eulerRotation.x:90;scale:Qt.vector3d(.33,.44,.33);materials:[grip]
                }
                Model {
                    source:"#Cube"
                    y:-25; z:24
                    eulerRotation.x:18
                    scale:Qt.vector3d(.23,.52,.32)
                    materials:[grip]
                }
                Model {
                    source:"#Sphere"
                    visible: recoil > .03
                    z:-82; y:12
                    scale:Qt.vector3d(recoil*.19,recoil*.22,recoil*.44)
                    materials:[hot]
                }
                Model {
                    source:"#Cone"
                    visible: view.bayonet && index === 1
                    y:-8; z:-73
                    eulerRotation.x:-90
                    scale:Qt.vector3d(.20,.63,.088)
                    materials:[rim]
                }
            }
        }
    }
    Node {
        id: rig
        visible: !view.handWeapon && !view.twins && !view.staff
        position: Qt.vector3d(9, -15 + view.pose.rise + view.stab * 14, view.pose.rear + 4 - view.stab * 105)
        eulerRotation: Qt.vector3d(view.pose.pitch-view.aimOffset.y*8.5,15-view.aimOffset.x*12,view.pose.roll)

        Repeater3D {
            model:view.weapon.id === "kingsRansom" ? 10 : 0
            delegate:Model {
                required property int index
                source:index%3 ? "#Cube" : "#Sphere"
                x:(index%2 ? 1 : -1)*view.art.width*.46
                y:13+index%3*3
                z:33-Math.floor(index/2)*15
                eulerRotation:Qt.vector3d(0,0,45)
                scale:Qt.vector3d(.055,.14,.055)
                materials:PrincipledMaterial {baseColor:index%3 ? "#ffe7a0" : "#65d7b2"; metalness:.86; roughness:.17}
            }
        }

        Repeater3D {
            model: view.weapon.id === "jesterScatter" ? 6 : 0
            delegate: Model {
                required property int index
                source: "#Cube"
                x: (index%3-1)*23
                y: 29+(index%3 === 1 ? 6 : 0)
                z: 34-index*14
                eulerRotation.z: (index%3-1)*19
                scale: Qt.vector3d(.10,.12,.42)
                materials: PrincipledMaterial {
                    baseColor: ["#fb6383","#ffd46e","#b1fa82","#5eeaff","#9867ff","#f88ddd"][index]
                    lighting: PrincipledMaterial.NoLighting
                }
            }
        }
        Model {
            source: "#Cone"
            visible: view.bayonet
            y: -12
            z: -view.art.barrel + 7
            eulerRotation.x: -90
            scale: Qt.vector3d(.19,.64,.084)
            materials: [rim]
        }
        Model {
            source: view.art.form === "cylinder" || view.art.form === "dish" ? "#Cylinder" : "#Cube"
            eulerRotation.x: source.toString().endsWith("#Cylinder") ? 90 : 0
            scale: source.toString().endsWith("#Cylinder")
                ? Qt.vector3d(view.art.width / 100, view.art.length / 100, view.art.height / 100)
                : Qt.vector3d(view.art.width * .0089, view.art.height * .0081, view.art.length / 100)
            materials: [enamel]
        }
        Model {
            source: "#Cube"
            y: view.art.height * .39
            z: 7 + view.pose.partTravel * (view.art.form === "slide" ? 1 : 0)
            scale: Qt.vector3d(view.art.width * .0066, .087, view.art.length * .009)
            materials: [rim]
        }
        Model {
            source: "#Cube"
            y: view.art.height * .51
            z: view.art.length * .19
            scale: Qt.vector3d(.19, .08, .14)
            materials: [dark]
        }
        Model {
            source: "#Cube"
            z: view.art.length * .4
            y: -view.art.height * .59
            eulerRotation.x: 17
            scale: Qt.vector3d(.32, .59, .41)
            materials: [grip]
        }
        Model {
            source: "#Sphere"
            z: view.art.length * .48
            x: -view.art.width * .09
            y: -view.art.height * .64
            scale: Qt.vector3d(.35, .39, .39)
            materials: [dark]
        }
        Repeater3D {
            model: view.art.vents * 2
            delegate: Model {
                required property int index
                readonly property int side: index % 2 ? 1 : -1
                source: "#Cube"
                x: side * view.art.width * .469
                y: view.art.height * .12
                z: view.art.length * (.38 - .78 * Math.floor(index / 2) / view.art.vents)
                scale: Qt.vector3d(.028, .105 + view.intensity * .026, .054)
                materials: [signal]
            }
        }
        Repeater3D {
            model: 2
            delegate: Node {
                id: sidePlate
                required property int index
                readonly property int side: index ? 1 : -1
                x: side * view.art.width * .41
                y: view.art.height * .23
                z: view.art.length * .07
                eulerRotation.z: side * -21
                Model {
                    source: "#Cube"
                    y: 4
                    scale: Qt.vector3d(.084, .137, view.art.length * .0072)
                    materials: [rim]
                }
                Model {
                    source: "#Cube"
                    y: -13
                    z: view.art.length * .19
                    scale: Qt.vector3d(.08, .17, view.art.length * .0037)
                    materials: [dark]
                }
                Model {
                    visible: ["cell", "split", "dish", "rail"].includes(view.art.form)
                    source: "#Cylinder"
                    x: sidePlate.side * 7
                    y: 5
                    z: -9
                    eulerRotation.x: 90
                    scale: Qt.vector3d(.097, view.art.length * .0061, .084)
                    opacity: .88
                    materials: [signal]
                }
            }
        }
        Repeater3D {
            model: Math.max(3, view.art.vents - 1)
            delegate: Model {
                required property int index
                source: "#Cube"
                y: view.art.height * .47
                z: view.art.length * .24 - 8 * index
                scale: Qt.vector3d(.24, .035, .021)
                materials: [dark]
            }
        }

        Repeater3D {
            model: view.weapon.id === "bilecaster" ? 2 : 0
            delegate: Node {
                required property int index
                x: (index ? 1 : -1) * view.art.width * .35
                y: 29 + view.pose.shellTravel * .50
                z: 19 + view.pose.shellTravel * .27
                eulerRotation.x: 90 + view.reloadRatio * (1 - view.reloadRatio) * 92
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(.215, .57, .215)
                    materials: [dark]
                }
                Model {
                    source: "#Cylinder"
                    scale: Qt.vector3d(.228 + view.intensity * .012, .37, .228)
                    materials: [signal]
                }
                Model {
                    source: "#Cylinder"
                    y: -22
                    scale: Qt.vector3d(.24, .05, .24)
                    materials: [rim]
                }
                Model {
                    source: "#Cylinder"
                    y: 22
                    scale: Qt.vector3d(.24, .05, .24)
                    materials: [rim]
                }
            }
        }
        Repeater3D {
            model: view.weapon.id === "blackHole" ? 8 : 0
            delegate: Model {
                required property int index
                readonly property real turn: index*Math.PI*.25 + (view.motion ? view.clock*1.3 : 0)
                source: "#Cube"
                position: Qt.vector3d(Math.cos(turn)*32,9+Math.sin(turn)*30,-view.art.barrel-5)
                eulerRotation.z: turn*180/Math.PI+45
                scale: Qt.vector3d(.115,.038,.18+view.intensity*.08)
                materials: [signal]
            }
        }
        Model {
            visible: view.weapon.id === "blackHole"
            source: "#Sphere"
            position: Qt.vector3d(0,9,-view.art.barrel-8)
            scale: Qt.vector3d(.39,.39,.20)
            materials: [cavity]
        }
        Repeater3D {
            model: view.weapon.id === "nightInk" || view.weapon.id === "whiteoutCoil" || view.weapon.id === "rimeRelay" ? 5 : 0
            delegate: Model {
                required property int index
                source:"#Cylinder"
                y: 22
                z: -view.art.barrel+19+index*11
                eulerRotation.x:90
                scale:Qt.vector3d(.35+view.intensity*.09,.043,.31+view.intensity*.08)
                materials:[index%2 ? rim : signal]
            }
        }
        Repeater3D {
            model: view.weapon.chargeEachShot ? 5 : 0
            Model {
                required property int index
                source: "#Cylinder"
                eulerRotation.x: 90
                z: -view.art.barrel + index * 19
                scale: Qt.vector3d(.39 + view.charge * .13, .044, .39 + view.charge * .13)
                opacity: .36 + view.charge * .64
                materials: [signal]
            }
        }
        Node {
            visible: !!view.art.scope
            y: view.art.height * .50 + 16
            z: -30
            Model {
                source: "#Cylinder"
                eulerRotation.x: 90
                scale: Qt.vector3d(.25, .70, .24)
                materials: [dark]
            }
            Model {
                source: "#Cylinder"
                z: 36
                eulerRotation.x: 90
                scale: Qt.vector3d(.22, .033, .22)
                materials: [signal]
            }
        }
        Node {
            z: -view.art.length * .47
            eulerRotation.x: view.pose.hinge
            Node {
                id: barrels
                eulerRotation.z: view.art.form === "rotary" ? view.pose.spin : 0

                Repeater3D {
                    model: view.art.form === "rotary" ? 6 : view.art.form === "split" || view.art.form === "break" ? 2
                        : view.weapon.id === "prism" ? 3 : 1
                    delegate: Node {
                        id: tube
                        required property int index
                        readonly property real angle: index * Math.PI / 3
                        x: view.art.form === "rotary" ? Math.cos(angle) * 22
                            : view.weapon.id === "prism" ? (index - 1) * 17
                            : view.art.form === "split" || view.art.form === "break" ? (index ? 15 : -15) : 0
                        y: view.art.form === "rotary" ? Math.sin(angle) * 22 : view.weapon.id === "prism" ? (index === 1 ? 11 : -4) : 2
                        Model {
                            source: "#Cylinder"
                            z: -view.art.barrel / 2
                            eulerRotation.x: 90
                            scale: Qt.vector3d(view.art.bore * .027, view.art.barrel / 100, view.art.bore * .027)
                            materials: [dark]
                        }
                        Model {
                            source: "#Cylinder"
                            z: -view.art.barrel + 3
                            eulerRotation.x: 90
                            scale: Qt.vector3d(view.art.bore * .034, .15, view.art.bore * .034)
                            materials: [rim]
                        }
                        Model {
                            source: "#Cylinder"
                            z: -view.art.barrel - 5
                            eulerRotation.x: 90
                            scale: Qt.vector3d(view.art.bore * .021, .022, view.art.bore * .021)
                            materials: [cavity]
                        }
                    }
                }
            }
            Repeater3D {
                model: view.art.form === "rotary" ? 2 : 0
                delegate: Model {
                    required property int index
                    source: "#Cylinder"
                    z: -view.art.barrel * (index === 0 ? .26 : .76)
                    eulerRotation.x: 90
                    scale: Qt.vector3d(.63, .080, .63)
                    materials: [index ? rim : enamel]
                }
            }
            Model {
                visible: view.art.form === "pump" || view.art.form === "rail" || view.art.form === "rotary"
                source: view.art.form === "rail" ? "#Cube" : "#Cylinder"
                z: -view.art.barrel * .40 + view.pose.partTravel
                y: view.art.form === "rail" ? 12 : -6
                eulerRotation.x: view.art.form === "rail" ? 0 : 90
                scale: view.art.form === "rail" ? Qt.vector3d(.54, .25, view.art.barrel * .006)
                    : Qt.vector3d(view.art.width * .0065, .39, .46)
                materials: [enamel]
            }
            Node {
                id: tip
                z: -view.art.barrel - 11
                Model {
                    visible: view.intensity > 0 && view.reloadRatio === 0
                    source: view.art.form === "dish" ? "#Sphere" : "#Cone"
                    eulerRotation.x: -90
                    z: -15
                    scale: Qt.vector3d(.21 + view.intensity * .15, .23 + view.intensity * .57, .21 + view.intensity * .15)
                    opacity: Math.min(1, view.intensity * 1.35)
                    materials: [signal]
                }
                Model {
                    visible: view.intensity > .2
                    source: "#Sphere"
                    z: -11
                    scale: Qt.vector3d(.15, .14, .23)
                    materials: [hot]
                }
            }
        }

        Model {
            z: view.art.length * .06
            y: -view.art.height * .60 - view.pose.shellTravel
            source: ["drum", "rotary", "cell", "dish"].includes(view.art.form) ? "#Cylinder" : "#Cube"
            eulerRotation: Qt.vector3d(view.art.form === "drum" ? 90 : view.pose.hinge * .7,
                view.art.form === "rotary" ? view.pose.shellTravel * .5 : 0, view.pose.roll * -.72)
            scale: view.art.form === "drum" ? Qt.vector3d(.77, .47, .78)
                : view.art.form === "rotary" ? Qt.vector3d(.56, .51, .61)
                : Qt.vector3d(.33, .46, .39)
            materials: [view.art.form === "cell" ? signal : dark]
        }
        Node {
            visible: view.art.form === "drum"
            x: -view.art.width * .41
            y: -16 - view.pose.shellTravel * .40
            z: -5
            eulerRotation.x: view.pose.shellTravel * .38
            Model {
                source: "#Cylinder"
                eulerRotation.z: 90
                scale: Qt.vector3d(.64, .15, .64)
                materials: [dark]
            }
            Repeater3D {
                model: 6
                delegate: Model {
                    required property int index
                    readonly property real angle: index * Math.PI / 3
                    source: "#Cylinder"
                    x: -8
                    y: Math.cos(angle) * 22
                    z: Math.sin(angle) * 22
                    eulerRotation.z: 90
                    scale: Qt.vector3d(.115, .050, .115)
                    materials: [signal]
                }
            }
        }
    }
}

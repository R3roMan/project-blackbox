import QtQuick
import QtQuick3D
import "Rules.js" as Rules
import "Elements.js" as Elements
import "AttackArt.js" as Attacks
import "CreatureLivery.js" as Livery

Node {
    id: actor

    required property var enemy
    required property int revision

    property real blindness: 0
    property string viewedFront: "front"
    property int grabId: 0
    readonly property var creature: Rules.enemyTypes[enemy.type]
    readonly property bool angel: creature.role === "angel" || !!creature.angel
    readonly property bool shade: enemy.type === "mystery"
    readonly property bool meteor: enemy.type === "meteor"
    readonly property bool ninja: enemy.type === "nindumipus"
    readonly property bool ice: enemy.type === "iceterapus"
    readonly property bool saucer: enemy.type === "claptrap" || enemy.type === "jon"
    readonly property bool anger: { revision; return enemy.anger || false }
    readonly property bool cover: { revision; return enemy.type === "jos" && enemy.front === viewedFront }
    readonly property var pose: Attacks.pose(enemy)
    readonly property real jawOpen: Math.max(0, strike)*pose[3]+(warning ? Math.abs(strike)*.15 : 0)
    readonly property real strike: { revision; return Attacks.amount(enemy, warning, animate) }
    opacity: shade || creature.voidBoss ? 1 : 1 - blindness * .94
    readonly property bool alien: creature.role === "alien"
    readonly property var details: Livery.details[enemy.type]
    readonly property bool crawler: creature.role === "void"
    readonly property bool abyssRig: creature.abyss && !shade && !creature.voidBoss
        || ["archfellanus","lalaBubu","skorochiyus","crufixicatus"].includes(enemy.type)
    readonly property bool boss: creature.role === "boss"
    readonly property bool spinner: enemy.type === "mastafangenbus"
    readonly property bool executioner: enemy.type === "capablancamus"
    readonly property bool teeth: enemy.type === "zadrrimus"
    readonly property bool tongue: enemy.type === "rerogorubus"
    readonly property bool fatRig:enemy.type==="papapoganus" || enemy.type==="oblogabgalus"
    readonly property bool mother: enemy.type === "mothergalian"
    readonly property bool dragon: enemy.type === "gigafinterus"
    readonly property bool prince: enemy.type === "princoratus"
    readonly property string condition: { revision; return Elements.visible(enemy.elements) }
    readonly property bool frozen: { revision; return !!enemy.elements && enemy.elements.frozen > 0 }
    readonly property color conditionColor: condition ? Elements.kinds[condition].color : creature.accent
    readonly property real shatter: { revision; return enemy.shatter || 0 }
    readonly property real size: Rules.enemySize(enemy)
    property bool animate: true
    property bool preview:false
    readonly property real age: { revision; return enemy.age }
    readonly property real dodgeLean: {
        revision
        return animate && enemy.dodgeAge > 0 ? -Math.sign(enemy.dodgeLaneGoal) * 22 * Math.sin(enemy.dodgeAge / .47 * Math.PI) : 0
    }
    readonly property bool warning: { revision; return Rules.charging(enemy) }
    readonly property bool hurt: { revision; return enemy.flash > 0 }
    readonly property real hurtFace: {revision; return (enemy.hurtFace || 0)/.38}
    readonly property bool shielded: { revision; return enemy.barrier > 0 }
    readonly property bool roaring: { revision; return enemy.roar > 0 }
    readonly property bool ghost: { revision; return Rules.ghosted(enemy) }
    readonly property real warp: { revision; return Rules.warpFraction(enemy) }
    readonly property real arrival: { revision; return Rules.materialization(enemy) }
    readonly property real gate: warp > 0 ? Math.sin((1 - warp) * Math.PI) : 0
    readonly property real flap: animate && warp <= 0 ? Math.sin(age * 10) : 0
    readonly property bool customArrival: ["liquid","rise","divine","alienArrival","sink"].includes(enemy.warpKind)

    eulerRotation: {
        revision
        const location = Rules.front(enemy.front)
        return Qt.vector3d(location.pitch, location.yaw, 0)
    }

    PrincipledMaterial {
        id: outer
        baseColor: actor.anger ? "#efacb6" : actor.ghost ? "#80848d" : actor.frozen ? "#8ccdf4" : actor.hurt ? actor.creature.accent : actor.creature.skin
        roughness: 0.76
    }
    PrincipledMaterial { id: bone; baseColor: actor.ghost ? "#a0a1a6" : Qt.lighter(actor.creature.skin, 1.45); roughness: 0.78 }
    PrincipledMaterial {
        id: membrane
        baseColor: actor.ghost ? "#737680" : Qt.darker(actor.creature.skin, 1.21)
        roughness: 0.82
    }
    PrincipledMaterial {
        id: light
        baseColor: actor.anger ? "#ff476a" : actor.ghost ? "#c7cbd1" : actor.warning ? Qt.lighter(actor.creature.accent, 1.35) : actor.creature.accent
        lighting: PrincipledMaterial.NoLighting
    }
    PrincipledMaterial { id: dark; baseColor: "#1e1322"; lighting: PrincipledMaterial.NoLighting }
    PrincipledMaterial { id: enamel; baseColor: actor.ghost ? "#acb0b5" : "#f1d7b7"; roughness: 0.65 }
    PrincipledMaterial {
        id: gateLight
        baseColor: { actor.revision; return Rules.warpColor(actor.enemy) }
        lighting: PrincipledMaterial.NoLighting
    }
    PrincipledMaterial { id: saliva; baseColor: "#e14d77"; roughness: .28 }
    PrincipledMaterial { id: shieldLight; baseColor: "#79e3ff"; lighting: PrincipledMaterial.NoLighting }

    PrincipledMaterial { id: charged; baseColor: actor.conditionColor; lighting: PrincipledMaterial.NoLighting }

    Node {
        id: centre
        position: {
            actor.revision
            return Qt.vector3d(Rules.lanePosition(actor.enemy), Rules.elevation(actor.enemy), -actor.enemy.depth)
        }
        scale: Qt.vector3d(actor.size, actor.size, actor.size)

        Node {
            id: body
            opacity: actor.arrival * (actor.ghost ? .32 : 1)
            z: actor.pose[2] * actor.strike
            eulerRotation.x: actor.pose[0] * actor.strike
            eulerRotation.z: (actor.spinner && actor.animate && !actor.preview ? actor.age * 165 : actor.crawler ? 0 : actor.flap * 2.5)
                + actor.pose[1] * actor.strike + actor.dodgeLean + (actor.animate ? Math.sin(actor.age*61)*actor.hurtFace*5 : 0)
            eulerRotation.y: {
                actor.revision
                return actor.spinner && actor.animate && !actor.preview ? actor.age * 255 : actor.enemy.feedYaw || 0
            }

            Loader3D {
                active: actor.creature.origin === "Hellborne" && !actor.creature.vampire && actor.enemy.type !== "saslimigus"
                sourceComponent: Node {
                    SickleHornGeometry { id: hornShape }
                    ScallopedWingGeometry { id: wingShape }
                    PrincipledMaterial { id: hornIvory; baseColor: Qt.lighter(actor.creature.skin,1.65); roughness:.65; cullMode:Material.NoCulling }
                    PrincipledMaterial { id: wingHide; baseColor:Qt.darker(actor.creature.skin,1.35); roughness:.72; cullMode:Material.NoCulling }
                    Repeater3D {
                        model:[-1,1]
                        Node {
                            required property int modelData
                            scale:Qt.vector3d(modelData,1,1)
                            Model {geometry:hornShape;position:Qt.vector3d(22,60,18);materials:[hornIvory]}
                            Model {
                                geometry:wingShape
                                position:Qt.vector3d(38,10,-24)
                                eulerRotation.y:14+actor.flap*24
                                scale:actor.creature.devour ? Qt.vector3d(.52,.52,.52) : Qt.vector3d(1,1,1)
                                materials:[wingHide]
                            }
                        }
                    }
                }
            }
            Loader3D {
                active:!!actor.creature.vampire
                sourceComponent:BlandromedusRig {
                    targetId:actor.enemy.id
                    clock:actor.animate ? actor.age : .35
                    strike:actor.strike
                    live:actor.warp<=0
                    angry:actor.hurt
                }
            }
            Loader3D {
                objectName:"fatDemonLoader"
                active:actor.fatRig
                sourceComponent:FatDemonRig {
                    enemy:actor.enemy
                    revision:actor.revision
                    live:actor.warp<=0
                    molt:{actor.revision;return actor.enemy.trainingMolt || (actor.enemy.anger ? 1 : 0)}
                }
            }
            Loader3D {
                active: actor.angel && !actor.abyssRig
                sourceComponent: AngelRig {
                    targetId: actor.enemy.id
                    kind: actor.enemy.type
                    skin: actor.creature.skin
                    glow: actor.creature.accent
                    strike: actor.strike
                    age: actor.age
                    fuse: { actor.revision; return actor.enemy.fuse || 0 }
                    cover: actor.cover
                    live: actor.warp <= 0
                    animate: actor.animate
                    rushing: { actor.revision; return actor.enemy.type === "lucifoverus" && actor.enemy.recover <= 0
                        && actor.enemy.warp <= 0 && actor.enemy.depth > actor.creature.reach }
                }
            }
            Loader3D {
                active: !!actor.creature.battlestar
                sourceComponent: BattlestarRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    charging: { actor.revision; return actor.enemy.beamWarning > 0 }
                    beaming: { actor.revision; return actor.enemy.beamLeft > 0 }
                    clock: actor.animate ? actor.age : 0
                }
            }
            Loader3D {
                active: !!actor.creature.skeleton
                sourceComponent: SkeletalRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    clock: actor.animate ? actor.age : 0
                    beam: { actor.revision; return actor.enemy.beamLeft > 0 ? 1 : actor.enemy.beamWarning > 0 ? .55 : 0 }
                }
            }
            Loader3D {
                active: !!actor.creature.triad
                sourceComponent: MagnetRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    warning: actor.warning
                    clock: actor.animate ? actor.age : 0
                }
            }
            Loader3D {
                active: !!actor.creature.serpent
                sourceComponent: SerpentRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    phase: actor.animate ? actor.age : 0
                    strike: actor.strike
                    charging: actor.warning
                }
            }
            Loader3D {
                active: !!actor.creature.sniper
                sourceComponent: FetaRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    clock: actor.animate ? actor.age : 0
                    aiming: actor.warning
                    recoil: Math.max(0,actor.strike)
                }
            }
            Loader3D {
                active: !!actor.creature.devour
                sourceComponent: DevourerRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    clock: actor.animate ? actor.age : 0
                    openness: {
                        actor.revision
                        return actor.enemy.feed ? Math.max(.18,Math.sin(Math.PI * actor.enemy.feed.time/1.02))
                            : Math.min(1, Math.abs(actor.strike)*1.3)
                    }
                    healing: { actor.revision; return actor.enemy.feedingHeal || 0 }
                    hurt: actor.hurt
                }
            }
            Loader3D {
                active: actor.abyssRig
                sourceComponent: AbyssRig {
                    enemy: actor.enemy
                    revision: actor.revision
                    animate: actor.animate
                    live: actor.warp <= 0
                    tell: { actor.revision; return Rules.warningProgress(actor.enemy) }
                    grabbing: actor.grabId === actor.enemy.id
                }
            }
            Loader3D {
                active: !!actor.creature.voidBoss
                sourceComponent: VoidGlitchRig {
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    time: actor.animate ? actor.age : .45
                    warning: actor.warning
                }
            }
            Repeater3D {
                model: actor.details ? actor.details[0] : 0
                delegate: Model {
                    required property int index
                    readonly property var mark: actor.details
                    readonly property real offset: index - (mark[0] - 1) * .5
                    source: mark[4] === "rib" ? "#Cylinder" : mark[4] === "blade" ? "#Cone" : "#Cube"
                    x: offset * mark[1]
                    y: -20 - (mark[2] + mark[3]) * Math.abs(offset) * .20
                    z: actor.crawler ? 43 : 54 - Math.abs(offset) * 7
                    eulerRotation: Qt.vector3d(17 + mark[3], mark[4] === "gem" ? 35 : 0, mark[4] === "rib" ? 74 : offset * 16)
                    scale: Qt.vector3d(.10,.14 + mark[2] * .003,.07 + mark[3] * .002)
                    materials: [index % 2 ? bone : (mark[4] === "gem" ? light : membrane)]
                }
            }
            Loader3D {
                active: !!actor.creature.slime
                sourceComponent: SlimeRig {
                    targetId: actor.enemy.id
                    horned: actor.boss
                    live: actor.warp <= 0
                    warning: actor.warning
                    motion: actor.animate
                    skin: actor.hurt ? Qt.lighter(actor.creature.skin, 1.48) : actor.creature.skin
                    accent: actor.creature.accent
                    age: actor.age
                    strike: actor.strike
                }
            }
            Loader3D {
                active: actor.shade || actor.meteor || actor.saucer || actor.ninja || actor.ice || actor.enemy.type === "gendoustagus"
                sourceComponent: CreatureDetails {
                    kind: actor.enemy.type
                    targetId: actor.enemy.id
                    skin: actor.creature.skin
                    accent: actor.creature.accent
                    strike: actor.strike
                    age: actor.age
                    live: actor.warp <= 0
                    animate: actor.animate
                    anger: actor.anger
                }
            }
            Node {
                visible: !actor.creature.vampire && !actor.fatRig && !actor.angel && !actor.shade && !actor.meteor && !actor.saucer && !actor.creature.slime
                    && !actor.creature.battlestar && !actor.creature.skeleton && !actor.creature.triad && !actor.creature.serpent
                    && !actor.creature.sniper && !actor.creature.devour && !actor.creature.voidBoss && !actor.abyssRig


                Model {
                    objectName: String(actor.enemy.id)
                    source: "#Sphere"
                    scale: actor.dragon ? Qt.vector3d(1.26, 1.02, 1.21) : actor.alien ? Qt.vector3d(1.48, 0.90, 0.82)
                        : actor.crawler ? Qt.vector3d(1.04, 0.72, 0.58) : Qt.vector3d(1.34, 1.38, 0.86)
                    materials: [outer]
                    pickable: actor.warp === 0
                }
                Model {
                    objectName: String(actor.enemy.id)
                    visible: !actor.alien && !actor.crawler
                    source: "#Sphere"
                    y: actor.dragon ? 43 : 49
                    z: actor.dragon ? 46 : 22
                    scale: actor.dragon ? Qt.vector3d(.76, .41, .68) : Qt.vector3d(.63, .55, .52)
                    materials: [bone]
                    pickable: visible && actor.warp === 0
                }
                Model {
                    source: "#Cone"
                    visible: actor.boss
                    y: 101
                    z: 23
                    scale: Qt.vector3d(.28, .68, .29)
                    materials: [light]
                }
                Repeater3D {
                    model: actor.executioner ? 5 : 0
                    delegate: Model {
                        required property int index
                        source: "#Cone"
                        x: (index-2)*13
                        y: 82 + (index === 2 ? 13 : 0)
                        z: 48
                        scale: Qt.vector3d(.13,index === 2 ? .39 : .24,.14)
                        materials: [light]
                    }
                }

                // The face sits in front of the head or central shell.
                Node {
                    y: actor.alien || actor.crawler ? 0 : 50
                    z: actor.crawler ? 25 : actor.alien ? 40 : actor.dragon ? 77 : 48

                    Model {
                        source: "#Sphere"
                        y: actor.crawler ? 0 : 9
                        z: 8
                        scale: actor.crawler ? Qt.vector3d(0.44, 0.42, 0.15) : Qt.vector3d(.41,.32*(1-actor.hurtFace*.50),.18)
                        materials: [light]
                    }
                    Model {
                        source: "#Sphere"
                        visible: !actor.crawler
                        y: 9
                        z: 20
                        scale: Qt.vector3d(.095,.225,.059)
                        materials: [dark]
                    }
                    Node {
                        readonly property bool belly: Livery.bellyMaws.includes(actor.enemy.type)
                        y: belly ? -54 : 0
                        z: belly ? 7 : 0
                        scale: belly ? Qt.vector3d(1.78,1.48,1.15) : Qt.vector3d(1,1,1)
                        Model {
                            source: "#Sphere"
                            visible: !actor.crawler
                            y: actor.teeth ? -23 : -15-actor.jawOpen*19
                            z: actor.teeth ? 21 : 13
                            scale: actor.teeth ? Qt.vector3d(.47, .32 + (Math.max(0, actor.strike) * .29), .16)
                                : actor.dragon ? Qt.vector3d(.43, .18 + Math.abs(actor.strike) * .24, .16)
                                : actor.tongue ? Qt.vector3d(.39, .22, .13)
                                : Qt.vector3d(.34,.09+actor.jawOpen*1.19,.16)
                            materials: [dark]
                        }
                        Repeater3D {
                            model: 2
                            delegate: Model {
                                required property int index
                                source: "#Cube"
                                visible: !actor.crawler && !actor.teeth
                                x: index === 0 ? -6 : 6
                                y: actor.roaring ? -8 : -13+actor.jawOpen*23
                                z: 22
                                eulerRotation.x: actor.jawOpen*29
                                scale: Qt.vector3d(.055,.095,.039)
                                materials: [enamel]
                            }
                        }
                        Model {
                            visible: !actor.crawler && !actor.teeth && !actor.dragon
                            source:"#Sphere"
                            y:-24-actor.jawOpen*61
                            z:12+actor.jawOpen*14
                            eulerRotation.x:actor.jawOpen*38
                            scale:Qt.vector3d(.42,.13,.32)
                            materials:[bone]
                        }
                        Repeater3D {
                            model: !actor.crawler && !actor.teeth && !actor.dragon ? 4 : 0
                            delegate: Model {
                                required property int index
                                source:"#Cone"
                                x:(index-1.5)*6
                                y:-21-actor.jawOpen*55
                                z:25+actor.jawOpen*17
                                scale:Qt.vector3d(.043,.076,.05)
                                materials:[enamel]
                            }
                        }
                        Repeater3D {
                            model: actor.teeth ? 10 : 0
                            delegate: Model {
                                required property int index
                                source: "#Cone"
                                visible: actor.teeth
                                x: (index % 5 - 2) * 7
                                y: index < 5 ? -13 : -34
                                z: 28
                                eulerRotation.z: index < 5 ? 180 : 0
                                scale: Qt.vector3d(.065, index % 3 === 0 ? .134 : .103, .07)
                                materials: [enamel]
                            }
                        }
                        Model {
                            visible: actor.tongue
                            source: "#Sphere"
                            y: -25
                            z: 23 + actor.flap * 3 + Math.abs(actor.strike) * 25
                            eulerRotation.z: actor.flap * 30
                            scale: Qt.vector3d(.087, .34 + Math.abs(actor.strike) * .24, .10)
                            materials: [saliva]
                        }
                    }
                }

                Repeater3D {
                    model: actor.dragon ? 6 : 0
                    delegate: Model {
                        required property int index
                        visible: actor.dragon
                        readonly property real sweep: actor.animate ? Math.sin(actor.age * 4.4 - index * .43) : .35
                        objectName: String(actor.enemy.id)
                        pickable: actor.warp <= 0
                        source: "#Sphere"
                        x: 23 + 22 * index + sweep * (14 + 3 * index)
                        y: -30 - 5 * index
                        z: -40 - 23 * index
                        eulerRotation.y: -29 + sweep * 32
                        scale: Qt.vector3d(.44 - index * .05, .44 - index * .065, .58 - index * .04)
                        materials: [index % 2 ? outer : membrane]
                    }
                }
                Model {
                    visible: actor.prince
                    source: "#Cone"
                    z: 44
                    y: -28
                    eulerRotation.x: 88
                    scale: Qt.vector3d(.40, .22, .31)
                    materials: [charged]
                }

                Repeater3D {
                    model: actor.mother ? 3 : 0
                    delegate: Model {
                        required property int index
                        source: "#Sphere"
                        visible: actor.mother
                        x: (index - 1) * 29
                        y: -31 + (index % 2) * -8
                        z: 23
                        scale: Qt.vector3d(.16, .26, .15)
                        materials: [bone]
                    }
                }

                Repeater3D {
                    model: [-1, 1]
                    delegate: Model {
                        required property int modelData
                        objectName: String(actor.enemy.id)
                        visible: !actor.alien && actor.creature.origin !== "Hellborne"
                        source: "#Cone"
                        x: modelData * (actor.crawler ? 52 : 28)
                        y: actor.crawler ? -12 : 73
                        z: 16
                        eulerRotation.z: modelData * (actor.crawler ? -118 : -28)
                        scale: actor.crawler ? Qt.vector3d(0.28, 0.91, 0.31) : Qt.vector3d(0.22, 0.67, 0.29)
                        pickable: visible && !actor.crawler && actor.warp === 0
                        materials: [bone]
                    }
                }

                Repeater3D {
                    model: [-1, 1]
                    delegate: Node {
                        required property int modelData
                        visible: !actor.crawler
                        x: modelData * 43
                        y: 13
                        z: -22
                        eulerRotation.y: modelData * (12 + actor.flap * 27)
                        eulerRotation.z: modelData * (11 + actor.flap * 16 + actor.strike * actor.pose[4])

                        Model {
                            objectName: String(actor.enemy.id)
                            source: "#Cone"
                            visible: actor.creature.origin !== "Hellborne"
                            x: modelData * 48
                            y: 16
                            eulerRotation.z: modelData * -63
                            scale: Qt.vector3d(0.68, 1.48, 0.18)
                            pickable: actor.warp === 0
                            materials: [membrane]
                        }
                        Model {
                            objectName: String(actor.enemy.id)
                            source: "#Cone"
                            x: modelData * 31
                            y: -22
                            z: -3
                            eulerRotation.z: modelData * -137
                            scale: Qt.vector3d(0.44, 0.93, 0.18)
                            pickable: actor.warp === 0
                            materials: [outer]
                        }
                        Model {
                            visible: actor.executioner
                            source: "#Cone"
                            x: modelData * 55
                            y: 1
                            z: 25
                            eulerRotation.z: -modelData * (62 + actor.strike * 21)
                            scale: Qt.vector3d(.19,1.07,.15)
                            materials: [enamel]
                        }
                    }
                }
            }
        }

        Model {
            visible: actor.shielded && actor.arrival > 0
            source: "#Sphere"
            scale: Qt.vector3d(2.74, 1.35, 1.18)
            opacity: 0.25 * actor.arrival
            materials: [shieldLight]
        }

        Repeater3D {
            model: 7
            delegate: Model {
                required property int index
                visible: actor.condition.length > 0
                readonly property real angle: index * .897 + (actor.animate ? actor.age * .85 : 0)
                readonly property real flicker: actor.animate ? Math.sin(actor.age * 17 + index) : 0
                source: actor.condition === "freeze" ? "#Cone" : "#Sphere"
                x: Math.cos(angle) * 84
                y: Math.sin(angle) * 49 + (actor.condition === "burn" ? 18 + flicker * 18 : 0)
                z: 45
                eulerRotation.z: index * 46
                opacity: .57 + flicker * .16
                scale: actor.condition === "explosive" ? Qt.vector3d(.12, .12, .12)
                    : Qt.vector3d(.10, .18 + flicker * .045, .09)
                materials: [charged]
            }
        }

        Repeater3D {
            model: 8
            delegate: Model {
                required property int index
                readonly property real angle: index * Math.PI * .25
                visible: actor.shatter > 0
                readonly property real burst: 1 - actor.shatter / .48
                source: "#Cone"
                x: Math.cos(angle) * (86 + burst * 74)
                y: Math.sin(angle) * (43 + burst * 66)
                z: 39
                eulerRotation.z: index * 45 + burst * 170
                scale: Qt.vector3d(.09, .25, .035)
                opacity: actor.shatter / .48
                materials: [shieldLight]
            }
        }

        Model {
            visible: actor.warp > 0 && !actor.customArrival
            source: "#Sphere"
            z: -34
            scale: Qt.vector3d(0.75 + actor.gate * 1.20, 1.90, 0.065)
            opacity: actor.gate * 0.54
            materials: [gateLight]
        }
        Model {
            visible: actor.warp > 0 && !actor.customArrival
            source: "#Cube"
            z: 38
            scale: Qt.vector3d(0.070 + actor.gate * 0.28, 2.06, 0.032)
            opacity: actor.gate * 0.78
            materials: [gateLight]
        }
    }
}

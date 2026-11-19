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
    property var surfaces:null
    property bool simplified:false
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
    readonly property real windup: { revision; return Rules.warningProgress(enemy) }
    readonly property real jawOpen: Math.max(Math.max(0,-strike)*1.55, Math.max(0,strike)*.53)*pose[3]
    readonly property real strike: { revision; return Attacks.amount(enemy, windup, animate) }
    opacity: shade || creature.voidBoss ? 1 : 1 - blindness * .94
    readonly property bool alien: creature.role === "alien"
    readonly property bool fighter: ["spartalien","fizzalien","mothergalian","veilskate"].includes(enemy.type)
    readonly property var details: Livery.details[enemy.type]
    readonly property bool crawler: creature.role === "void"
    readonly property bool abyssRig: creature.abyss && !shade && !creature.voidBoss
        || ["archfellanus","lalaBubu","skorochiyus","crufixicatus"].includes(enemy.type)
    readonly property bool boss: creature.role === "boss"
    readonly property bool spinner: enemy.type === "mastafangenbus"
    readonly property bool executioner: enemy.type === "capablancamus"
    readonly property bool teeth: enemy.type === "zadrrimus"
    readonly property bool tongue: enemy.type === "rerogorubus"
    readonly property bool belly:Livery.bellyMaws.includes(enemy.type)
    property int bellyStyle:0
    readonly property bool fatRig:enemy.type==="papapoganus" || enemy.type==="oblogabgalus"
    readonly property bool mother: enemy.type === "mothergalian"
    readonly property bool dragon: enemy.type === "gigafinterus"
    readonly property bool prince: enemy.type === "princoratus"
    readonly property string condition: { revision; return Elements.visible(enemy.elements) }
    readonly property bool frozen: { revision; return !!enemy.elements && enemy.elements.frozen > 0 }
    readonly property Material iceMaterial:frozen ? frostShell : null
    readonly property color conditionColor: condition ? Elements.kinds[condition].color : creature.accent
    readonly property real shatter: { revision; return enemy.shatter || 0 }
    readonly property real size: Rules.enemySize(enemy)
    property bool animate: true
    PrincipledMaterial {
        id: frostShell
        baseColor:"#abdafa";roughness:.23;metalness:.14;specularAmount:.82;cullMode:Material.NoCulling
    }
    property bool preview:false
    readonly property real age: { revision; return enemy.age }
    readonly property real dodgeLean: {
        revision
        return animate && enemy.dodgeAge > 0 ? -Math.sign(enemy.dodgeLaneGoal) * 22 * Math.sin(enemy.dodgeAge / .47 * Math.PI) : 0
    }
    readonly property bool warning: { revision; return Rules.charging(enemy) }
    readonly property bool stormLit: {revision;return !!enemy.stormCharged}
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

    LitSurface {
        surfaces:actor.surfaces;finish:"hide"
        id:outer
        baseColor: actor.anger ? "#efacb6" : actor.ghost ? "#80848d" : actor.frozen ? "#8ccdf4" : actor.hurt ? actor.creature.accent : actor.creature.skin
        roughness:actor.boss && actor.surfaces?.detailed ? .49 : .76
    }
    LitSurface {
        surfaces:actor.surfaces;finish:"bone"
        id:bone; baseColor: actor.ghost ? "#a0a1a6" : Qt.lighter(actor.creature.skin, 1.45); roughness: 0.78 }
    LitSurface {
        surfaces:actor.surfaces;finish:"weave"
        id:membrane
        baseColor: actor.ghost ? "#737680" : Qt.darker(actor.creature.skin, 1.21)
        roughness: 0.82
    }
    PrincipledMaterial {
        id: light
        baseColor: actor.stormLit ? "#fff1ff" : actor.anger ? "#ff476a" : actor.ghost ? "#c7cbd1" : actor.warning ? Qt.lighter(actor.creature.accent, 1.35) : actor.creature.accent
        lighting: PrincipledMaterial.NoLighting
    }
    PrincipledMaterial { id: dark; baseColor: "#1e1322"; lighting: PrincipledMaterial.NoLighting }
    LitSurface {
        surfaces:actor.surfaces;finish:"bone"
        id:enamel; baseColor: actor.ghost ? "#acb0b5" : "#f1d7b7"; roughness: 0.65 }
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
            if (actor.preview)
                return Qt.vector3d(0,actor.animate ? Math.sin(actor.age*3.2)*6 : 0,0)
            return Qt.vector3d(Rules.lanePosition(actor.enemy), Rules.elevation(actor.enemy), -actor.enemy.depth)
        }
        scale: Qt.vector3d(actor.size, actor.size, actor.size)
        Loader3D {
            active:actor.boss && !actor.preview && !!actor.surfaces?.detailed && actor.warp<=0
            sourceComponent:BossPresence3D {
                enemy:actor.enemy
                revision:actor.revision
                tint:actor.creature.accent
                motion:actor.animate
            }
        }

        Node {
            id: body
            readonly property real crumble: {actor.revision;return actor.enemy.crumble || 0}
            opacity: actor.arrival * (actor.ghost ? .32 : 1) * (1-crumble*.65)
            z: actor.pose[2] * actor.strike
            y: -crumble*34
            eulerRotation.x: actor.pose[0] * actor.strike
            eulerRotation.z: (actor.spinner && actor.animate && !actor.preview ? actor.age * 165 : actor.crawler ? 0 : actor.flap * 2.5)
                + actor.pose[1] * actor.strike + actor.dodgeLean + (actor.animate ? Math.sin(actor.age*61)*(actor.hurtFace*5+crumble*12) : 0)
            eulerRotation.y: {
                actor.revision
                return actor.spinner && actor.animate && !actor.preview ? actor.age * 255 : actor.enemy.feedYaw || 0
            }

            Loader3D {
                active: actor.creature.origin === "Hellborne" && !actor.creature.vampire
                    && !actor.angel && actor.enemy.type!=="skorochiyus"
                sourceComponent: Node {
                    SickleHornGeometry {id:hornShape; textured:!!actor.surfaces?.detailed}
                    ScallopedWingGeometry {id:wingShape; textured:!!actor.surfaces?.detailed}
                    LitSurface {
                        id:hornIvory
                        surfaces:actor.surfaces
                        finish:"horn"
                        baseColor:Qt.lighter(actor.creature.skin,1.65)
                        roughness:.58
                        cullMode:Material.NoCulling
                    }
                    LitSurface {
                        id:wingHide
                        surfaces:actor.surfaces
                        finish:"wing"
                        baseColor:Qt.darker(actor.creature.skin,1.35)
                        roughness:.72
                        cullMode:Material.NoCulling
                    }
                    Repeater3D {
                        model:[-1,1]
                        Node {
                            required property int modelData
                            scale:Qt.vector3d(modelData,1,1)
                            Model {
                                objectName:"outer:"+actor.enemy.id
                                pickable:visible && actor.warp===0
                                geometry:hornShape
                                visible:actor.enemy.type!=="saslimigus" && !actor.creature.skeleton
                                    && !actor.creature.serpent && !actor.creature.slime && actor.enemy.type!=="crufixicatus"
                                position:actor.fatRig ? Qt.vector3d(30,49,20) : actor.dragon
                                    ? Qt.vector3d(22,53,50) : Qt.vector3d(23,58,25)
                                scale:actor.fatRig ? Qt.vector3d(.78,.75,.85) : Qt.vector3d(1,1,1)
                                materials:actor.iceMaterial ? [actor.iceMaterial] : [hornIvory]
                            }
                            Model {
                                objectName:"outer:"+actor.enemy.id
                                pickable:actor.warp===0
                                geometry:wingShape
                                position:actor.fatRig ? Qt.vector3d(51,11,-28) : actor.enemy.type==="crufixicatus"
                                    ? Qt.vector3d(12,-20,-12) : Qt.vector3d(38,10,-24)
                                eulerRotation.x:actor.enemy.type==="crufixicatus" ? 180 : 0
                                eulerRotation.y:14+actor.flap*24
                                scale:actor.creature.devour || actor.enemy.type==="crufixicatus" ? Qt.vector3d(.52,.52,.52) : Qt.vector3d(1,1,1)
                                materials:actor.iceMaterial ? [actor.iceMaterial] : [wingHide]
                            }
                        }
                    }
                }
            }
            Loader3D {
                active:actor.fighter
                sourceComponent:AlienFighterRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces; enemy:actor.enemy; spec:actor.creature; live:actor.warp<=0; strike:actor.strike}
            }
            Loader3D {
                active:!!actor.creature.vampire
                sourceComponent:BlandromedusRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
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
                sourceComponent:FatDemonRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
                    enemy:actor.enemy
                    revision:actor.revision
                    windup:actor.windup
                    live:actor.warp<=0
                    molt:{actor.revision;return actor.enemy.trainingMolt || (actor.enemy.anger ? 1 : 0)}
                }
            }
            Loader3D {
                active: actor.angel && !actor.abyssRig
                sourceComponent: AngelRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
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
                sourceComponent: BattlestarRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    charging: { actor.revision; return actor.enemy.beamWarning > 0 }
                    beaming: { actor.revision; return actor.enemy.beamLeft > 0 }
                    clock: actor.animate ? actor.age : 0
                }
            }
            Loader3D {
                active: !!actor.creature.skeleton
                sourceComponent: SkeletalRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    clock: actor.animate ? actor.age : 0
                    beam: { actor.revision; return actor.enemy.beamLeft > 0 ? 1 : actor.enemy.beamWarning > 0 ? .55 : 0 }
                }
            }
            Loader3D {
                active: !!actor.creature.triad
                sourceComponent: MagnetRig { iceMaterial:actor.iceMaterial;
                    surfaces:actor.surfaces
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    warning: actor.warning
                    clock: actor.animate ? actor.age : 0
                }
            }
            Loader3D {
                active: !!actor.creature.serpent
                sourceComponent: SerpentRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    phase: actor.animate ? actor.age : 0
                    strike: actor.strike
                    charging: actor.warning
                }
            }
            Loader3D {
                active: !!actor.creature.sniper
                sourceComponent: FetaRig { iceMaterial:actor.iceMaterial;
                    surfaces:actor.surfaces
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    clock: actor.animate ? actor.age : 0
                    aiming: actor.warning
                    recoil: Math.max(0,actor.strike)
                }
            }
            Loader3D {
                active: !!actor.creature.devour
                sourceComponent: DevourerRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
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
                sourceComponent: AbyssRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
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
                sourceComponent: VoidGlitchRig { iceMaterial:actor.iceMaterial;
                    targetId: actor.enemy.id
                    live: actor.warp <= 0
                    time: actor.animate ? actor.age : .45
                    warning: actor.warning
                }
            }
            Repeater3D {
                model:actor.details ? actor.simplified ? Math.ceil(actor.details[0]*.5) : actor.details[0] : 0
                delegate: Model {
                    required property int index
                    readonly property var mark: actor.details
                    readonly property real offset:(actor.simplified ? index*2 : index)-(mark[0]-1)*.5
                    source: mark[4] === "rib" ? "#Cylinder" : mark[4] === "blade" ? "#Cone" : "#Cube"
                    x: offset * mark[1]
                    y: -20 - (mark[2] + mark[3]) * Math.abs(offset) * .20
                    z: actor.crawler ? 43 : 54 - Math.abs(offset) * 7
                    eulerRotation: Qt.vector3d(17 + mark[3], mark[4] === "gem" ? 35 : 0, mark[4] === "rib" ? 74 : offset * 16)
                    scale: Qt.vector3d(.10,.14 + mark[2] * .003,.07 + mark[3] * .002)
                    materials: actor.iceMaterial ? [actor.iceMaterial] : [index % 2 ? bone : (mark[4] === "gem" ? light : membrane)]
                }
            }
            Loader3D {
                active: !!actor.creature.slime
                sourceComponent: SlimeRig { iceMaterial:actor.iceMaterial; surfaces:actor.surfaces
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
                sourceComponent: CreatureDetails { iceMaterial:actor.iceMaterial;
                    surfaces:actor.surfaces
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
                visible: !actor.fighter && !actor.creature.vampire && !actor.fatRig && !actor.angel && !actor.shade && !actor.meteor && !actor.saucer && !actor.creature.slime
                    && !actor.creature.battlestar && !actor.creature.skeleton && !actor.creature.triad && !actor.creature.serpent
                    && !actor.creature.sniper && !actor.creature.devour && !actor.creature.voidBoss && !actor.abyssRig


                Model {
                    objectName: String(actor.enemy.id)
                    source: "#Sphere"
                    scale: actor.dragon ? Qt.vector3d(1.26, 1.02, 1.21) : actor.alien ? Qt.vector3d(1.48, 0.90, 0.82)
                        : actor.crawler ? Qt.vector3d(1.04, 0.72, 0.58) : Qt.vector3d(1.34, 1.38, 0.86)
                    materials: actor.iceMaterial ? [actor.iceMaterial] : [outer]
                    pickable: actor.warp === 0
                }
                Model {
                    objectName: String(actor.enemy.id)
                    visible: !actor.alien && !actor.crawler
                    source: "#Sphere"
                    y: actor.dragon ? 43 : 49
                    z: actor.dragon ? 46 : 22
                    scale: actor.dragon ? Qt.vector3d(.76, .41, .68) : Qt.vector3d(.63, .55, .52)
                    materials: actor.iceMaterial ? [actor.iceMaterial] : [bone]
                    pickable: visible && actor.warp === 0
                }
                Model {
                    source: "#Cone"
                    visible: actor.boss
                    y: 101
                    z: 23
                    scale: Qt.vector3d(.28, .68, .29)
                    materials: actor.iceMaterial ? [actor.iceMaterial] : [light]
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
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [light]
                    }
                }

                // The face sits in front of the head or central shell.
                Node {
                    y: actor.alien || actor.crawler ? 0 : 50
                    z: actor.crawler ? 25 : actor.alien ? 40 : actor.dragon ? 77 : 48

                    Model { objectName:"eye:"+actor.enemy.id; pickable:actor.warp===0;
                        source: "#Sphere"
                        y: actor.crawler ? 0 : 9
                        z: 8
                        scale: actor.crawler ? Qt.vector3d(0.44, 0.42, 0.15) : Qt.vector3d(.41,.32*(1-actor.hurtFace*.50),.18)
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [light]
                    }
                    Model { objectName:"eye:"+actor.enemy.id; pickable:visible && actor.warp===0;
                        source: "#Sphere"
                        visible: !actor.crawler
                        y: 9
                        z: 20
                        scale: Qt.vector3d(.095,.225,.059)
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [dark]
                    }
                    Repeater3D {
                        model:actor.creature.origin==="Hellborne" && !actor.simplified ? 4 : 0
                        Model {
                            required property int index
                            readonly property int side: index%2 ? 1 : -1
                            source: "#Sphere"
                            x: side*(index<2 ? 11 : 15)
                            y: index<2 ? 8 : 13
                            z: index<2 ? 15.7 : 13.4
                            eulerRotation.z: side*(index<2 ? 20 : -40)
                            scale: Qt.vector3d(.090,.018,.028)
                            materials: actor.iceMaterial ? [actor.iceMaterial] : [saliva]
                        }
                    }
                    Node {
                        id: jawFace
                        visible:!actor.belly && !actor.crawler
                        y:actor.teeth ? -26 : -17-actor.jawOpen*12
                        z:actor.teeth ? 22 : 15
                        readonly property real gape:(actor.teeth ? 13 : 7)+Math.max(0,actor.jawOpen)*18
                        readonly property real jawWidth:actor.teeth || actor.dragon ? .47 : .39
                        Model {
                            source:"#Sphere"
                            scale:Qt.vector3d(jawFace.jawWidth,jawFace.gape*.027,.13)
                            materials:actor.iceMaterial ? [actor.iceMaterial] : [dark]
                        }
                        Repeater3D {
                            model:actor.simplified ? 4 : actor.teeth ? 10 : 8
                            delegate:Model {
                                required property int index
                                readonly property int side:index%2 ? -1 : 1
                                source:"#Cone"
                                x:actor.simplified ? (index-1.5)*7.5 : (index-(actor.teeth ? 4.5 : 3.5))*4.3
                                y:side*(jawFace.gape*.61)
                                z:8+side*.85
                                eulerRotation.z:side>0 ? 180 : 0
                                scale:Qt.vector3d(.046,.065+index%3*.010,.045)
                                materials:actor.iceMaterial ? [actor.iceMaterial] : [enamel]
                            }
                        }
                        Model {
                            visible:actor.tongue
                            source:"#Sphere"
                            y:-7
                            z:13+actor.flap*3+Math.abs(actor.strike)*23
                            eulerRotation.z:actor.flap*26
                            scale:Qt.vector3d(.074,.27+Math.abs(actor.strike)*.24,.10)
                            materials:actor.iceMaterial ? [actor.iceMaterial] : [saliva]
                        }
                    }
                }

                Loader3D {
                    active:actor.belly
                    y:-15
                    z:44
                    sourceComponent:BellyMaw { iceMaterial:actor.iceMaterial;
                        surfaces:actor.surfaces
                        hide:actor.creature.skin
                        clock:actor.animate ? actor.age : 0
                        bite:Math.min(1,actor.jawOpen*1.6)
                        style:actor.bellyStyle
                        simplified:actor.simplified
                    }
                }
                Loader3D {
                    active:actor.creature.origin==="Hellborne" && !actor.dragon && !actor.ninja
                    sourceComponent:ShortDemonArms { iceMaterial:actor.iceMaterial;
                        surfaces:actor.surfaces
                        skin:actor.creature.skin
                        clock:actor.animate ? actor.age : 0
                        strike:actor.strike
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
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [index % 2 ? outer : membrane]
                    }
                }
                Model {
                    visible: actor.prince
                    source: "#Cone"
                    z: 44
                    y: -28
                    eulerRotation.x: 88
                    scale: Qt.vector3d(.40, .22, .31)
                    materials: actor.iceMaterial ? [actor.iceMaterial] : [charged]
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
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [bone]
                    }
                }

                Repeater3D {
                    model: [-1, 1]
                    delegate: Model {
                        required property int modelData
                        objectName: "outer:"+actor.enemy.id
                        visible: !actor.alien && actor.creature.origin !== "Hellborne"
                        source: "#Cone"
                        x: modelData * (actor.crawler ? 52 : 28)
                        y: actor.crawler ? -12 : 73
                        z: 16
                        eulerRotation.z: modelData * (actor.crawler ? -118 : -28)
                        scale: actor.crawler ? Qt.vector3d(0.28, 0.91, 0.31) : Qt.vector3d(0.22, 0.67, 0.29)
                        pickable: visible && !actor.crawler && actor.warp === 0
                        materials: actor.iceMaterial ? [actor.iceMaterial] : [bone]
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
                            objectName: "outer:"+actor.enemy.id
                            source: "#Cone"
                            visible: actor.creature.origin !== "Hellborne"
                            x: modelData * 48
                            y: 16
                            eulerRotation.z: modelData * -63
                            scale: Qt.vector3d(0.68, 1.48, 0.18)
                            pickable: actor.warp === 0
                            materials: actor.iceMaterial ? [actor.iceMaterial] : [membrane]
                        }
                        Model {
                            objectName: "outer:"+actor.enemy.id
                            source: "#Cone"
                            visible:actor.creature.origin!=="Hellborne"
                            x: modelData * 31
                            y: -22
                            z: -3
                            eulerRotation.z: modelData * -137
                            scale: Qt.vector3d(0.44, 0.93, 0.18)
                            pickable: actor.warp === 0
                            materials: actor.iceMaterial ? [actor.iceMaterial] : [outer]
                        }
                        Model {
                            visible: actor.executioner
                            source: "#Cone"
                            x: modelData * 55
                            y: 1
                            z: 25
                            eulerRotation.z: -modelData * (62 + actor.strike * 21)
                            scale: Qt.vector3d(.19,1.07,.15)
                            materials: actor.iceMaterial ? [actor.iceMaterial] : [enamel]
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

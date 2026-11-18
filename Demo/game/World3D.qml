import QtQuick
import QtQuick3D
import QtQuick3D.Helpers
import "Rules.js" as Rules
import "Pets.js" as Pets
import "Optics.js" as Optics
import "CutArt.js" as CutArt

View3D {
    id: world

    property var actors: []
    property var bolts: []
    property var axes: []
    property var splits: []
    property var shatters: []
    property var holes: []
    property var gifts: []
    property var flyingPet: null
    property var guestPet: null
    property var smokes: []
    property var bubbleBursts:[]
    property var abilityEvents:[]
    property real turnRatio: 1
    property real blindness: 0
    property int quality: 0
    property int detail:1
    property string transitionStyle:"cinematic"
    property real transitionStrength:1
    readonly property bool abyssTransition:(frontId === "down" || previousFront === "down") && frontId !== previousFront && turnRatio < 1
    property real wallpaperZoom: 1
    readonly property real pixelRatio: Math.max(1, Screen.devicePixelRatio)
    property bool voidIncursion: false
    property string sunlight: ""
    readonly property int autoHeight: detail === 0 ? 900
        : detail === 1 && (hypnotised || voidIncursion) ? 1080 : 1440
    readonly property real renderScale: Math.min(pixelRatio,(quality || autoHeight)/Math.max(1,height))
    readonly property real turnEdge: Math.min(1, Math.min(turnRatio, 1 - turnRatio) / .24)
    readonly property real wallBlend: abyssTransition || transitionStyle === "soft" ? 0 : turnEdge * turnEdge * (3 - 2 * turnEdge) * (1 - blindness)
    readonly property real cropV: 1 / Math.tan(28 * Math.PI / 180)
    property real elapsed: 0
    property real lungeDepth: 0
    property real lungeLane: 0
    property real magnification: 1
    property point lensCentre: Qt.point(.5,.5)
    property bool motion: true
    property url artDirectory: ""
    property string frontId: "front"
    property int revision: 0
    property int grabId: 0
    property bool hypnotised: false
    property real meleeReturn: 0
    property string previousFront: frontId
    readonly property var previousView: Rules.front(previousFront)
    readonly property var currentView: Rules.front(frontId)
    readonly property real yaw: previousView.yaw + (currentView.yaw - previousView.yaw) * turnRatio
    readonly property real pitch: abyssTransition || transitionStyle === "soft" ? (turnRatio < .5 ? previousView.pitch : currentView.pitch)
        : previousView.pitch + (currentView.pitch - previousView.pitch) * turnRatio

    explicitTextureWidth: Math.max(1, Math.round(width * renderScale))
    explicitTextureHeight: Math.max(1, Math.round(height * renderScale))
    renderMode: View3D.Offscreen
    camera: magnification > 1.001 ? lens : eye
    environment: SceneEnvironment {
        backgroundMode: SceneEnvironment.Transparent
        antialiasingMode:world.detail > 0 && world.explicitTextureWidth <= (world.detail === 2 ? 3840 : 2688) ? SceneEnvironment.MSAA : SceneEnvironment.NoAA
        antialiasingQuality:world.detail === 2 ? SceneEnvironment.High : SceneEnvironment.Medium
        aoEnabled:world.detail === 2
        aoStrength:56
        aoDistance:72
        aoBias:1.4
    }

    function pickTarget(x, y) {
        return pickTargets(x, y)[0] || 0
    }

    function scopedIntersections(x, y) {
        const u = lensCentre.x + (x / Math.max(1,width) - lensCentre.x) / magnification
        const v = lensCentre.y + (y / Math.max(1,height) - lensCentre.y) / magnification
        const direction = Qt.vector3d((u*2-1) * width/Math.max(1,height)/cropV,(1-v*2)/cropV,-1)
        return rayPickAll(eye.scenePosition,eye.mapDirectionToScene(direction).normalized())
    }

    function pickTargets(x, y) {
        const ids = new Set()
        const intersections = magnification > 1.001 ? scopedIntersections(x,y) : pickAll(x,y)
        for (let index = 0; index < intersections.length; index += 1) {
            const model = intersections[index].objectHit
            const id = model ? Number(model.objectName) : 0
            if (id > 0)
                ids.add(id)
        }
        const hits = []
        for (const enemy of actors) {
            if (enemy.front !== frontId || enemy.warp > 0 || enemy.hp <= 0 || enemy.waitingBoss
                || hypnotised && enemy.type !== "hallucination")
                continue
            let bodyHit = ids.has(enemy.id)
            if (!bodyHit && (enemy.type === "oblogabgalus" || enemy.trainingPeon)) {
                // Keep the solid centre of a practice target hittable while
                // its animated mesh or the new wallpaper is being uploaded.
                const centre = projection(Rules.lanePosition(enemy), Rules.elevation(enemy), enemy.depth)
                const radius = (enemy.trainingPeon ? 43 : 65) * Rules.enemySize(enemy)
                    * centre.scale * (1 - .35 * (enemy.trainingMolt || 0))
                bodyHit = Math.hypot(x - centre.x,(y - centre.y) * 1.15) <= radius
            }
            if (bodyHit) hits.push({ id:enemy.id, depth:enemy.depth })
            if (enemy.turrets) {
                for (const tube of enemy.turrets) {
                    if (tube.hp > 0 && ids.has(tube.targetId))
                        hits.push({ id:tube.targetId, depth:enemy.depth - 110 })
                }
            }
            for (const fang of enemy.fangs || []) {
                if (fang.hp <= 0)
                    continue
                const point = Rules.fangPoint(enemy,fang)
                const tip = projection(point.lane,point.elevation,point.depth)
                if (ids.has(fang.id) || Math.hypot((x-tip.x)*1.3,y-tip.y) <= Math.max(9,tip.scale*42))
                    hits.push({id:fang.id,depth:point.depth})
            }
        }
        for (const bolt of bolts) {
            if (hypnotised || !Rules.pickableBolt(bolt, frontId, meleeReturn))
                continue
            const point = Rules.projectilePoint(bolt)
            const screen = projection(point.lane, point.elevation, point.depth)
            if (ids.has(bolt.id) || Math.hypot(x - screen.x, y - screen.y) <= Math.max(7, Rules.boltRadius(bolt) * screen.scale))
                hits.push({ id:bolt.id, depth:point.depth })
        }
        for (const gift of gifts) {
            if (!hypnotised && gift.front === frontId && ids.has(gift.id))
                hits.push({ id:gift.id, depth:gift.depth })
        }
        hits.sort(function(first, second) { return first.depth - second.depth })
        return hits.map(function(hit) { return hit.id })
    }

    function projection(lane, elevation, depth) {
        if (magnification > 1.001 && turnRatio >= 1)
            return Optics.project(width,height,lane-lungeLane,elevation,depth-lungeDepth,lensCentre,magnification)
        const scenePoint = frontFrame.mapPositionToScene(Qt.vector3d(lane, elevation, -depth))
        const pos = world.mapFrom3DScene(scenePoint)
        return { x:pos.x, y:pos.y, scale:height * magnification / (2 * Math.tan(28 * Math.PI / 180) * Math.max(45, depth - lungeDepth)) }
    }

    Node {
        id: frontFrame
        readonly property var location: Rules.front(world.frontId)
        eulerRotation: Qt.vector3d(location.pitch, location.yaw, 0)
        ActorRoster {
            id:casts
            entries:world.detail>0 && !world.hypnotised ? world.abilityEvents.filter(function(effect) {return effect.front===world.frontId}) : []
        }
        Repeater3D {
            model:casts
            delegate:AbilityBurst3D {
                required property int actorId
                effect:casts.records[actorId]
                revision:world.revision
                aspect:world.width/Math.max(1,world.height)
                detail:world.detail
                motion:world.motion
            }
        }
    }

    PerspectiveCamera {
        id: eye
        position: frontFrame.mapPositionToScene(Qt.vector3d(world.lungeLane,0,-world.lungeDepth))
        eulerRotation: Qt.vector3d(world.pitch, world.yaw, 0)
        fieldOfView:56+(world.transitionStyle === "cinematic" ? Math.sin(world.turnRatio*Math.PI)*4*world.transitionStrength : 0)
        clipNear: 5
        clipFar: 12000
    }
    FrustumCamera {
        id: lens
        position: eye.position
        eulerRotation: eye.eulerRotation
        clipNear: eye.clipNear
        clipFar: eye.clipFar
        readonly property real vertical: clipNear / world.cropV
        readonly property real horizontal: vertical * world.width / Math.max(1,world.height)
        readonly property real driftX: (world.lensCentre.x * 2 - 1) * horizontal * (1 - 1/world.magnification)
        readonly property real driftY: (1 - world.lensCentre.y * 2) * vertical * (1 - 1/world.magnification)
        left: driftX - horizontal / world.magnification
        right: driftX + horizontal / world.magnification
        bottom: driftY - vertical / world.magnification
        top: driftY + vertical / world.magnification
    }

    DirectionalLight {
        eulerRotation: Qt.vector3d(world.sunlight ? -12 : -28, world.sunlight
            ? (world.sunlight==="sunrise" ? -56 : 65)+(world.motion ? Math.sin(world.elapsed*.023)*28 : 0)
            : -38,0)
        color: world.sunlight ? (world.sunlight==="sunrise" ? "#ffc07b" : "#ff8759")
            : world.detail === 2 ? "#ffb178" : "#ffc4a4"
        ambientColor: world.sunlight ? "#724470" : world.detail === 2 ? "#514765" : "#70617e"
        brightness: world.sunlight ? 2.55 : world.detail === 2 ? 2.15 : 1.8
        castsShadow:world.detail === 2
        shadowMapQuality:Light.ShadowMapQualityMedium
        shadowFactor:69
        shadowMapFar:3800
        softShadowQuality:Light.PCF4
    }
    DirectionalLight {
        eulerRotation: Qt.vector3d(38, 130, 0)
        color: "#91b2ff"
        brightness: 1.2
    }
    DirectionalLight {
        eulerRotation: Qt.vector3d(12, 100, 0)
        color: "#f6a168"
        brightness: 0.85
    }
    Loader3D {
        parent:frontFrame
        active:world.detail === 2
        sourceComponent:PointLight {
            position:Qt.vector3d(-280,240,-480)
            color:"#ff8059"
            brightness:1.65
            quadraticFade:.19
        }
    }

    Repeater3D {
        model: String(world.artDirectory).length ? Rules.fronts : []
        delegate: Node {
            id: wall
            required property var modelData
            eulerRotation: Qt.vector3d(modelData.pitch, modelData.yaw, 0)
            Model {
                visible: world.turnRatio > 0 && world.turnRatio < 1 && world.wallBlend > .01
                opacity: world.wallBlend
                source: "#Rectangle"
                z: -4500
                scale: Qt.vector3d(90.02, 90.02, 1)
                materials: PrincipledMaterial {
                    lighting: PrincipledMaterial.NoLighting
                    cullMode: Material.NoCulling
                    baseColorMap: Texture {
                        source: Qt.resolvedUrl(String(world.artDirectory) + wall.modelData.art)
                        scaleU: world.cropV * world.height / Math.max(1, world.width) / world.wallpaperZoom
                        scaleV: world.cropV / world.wallpaperZoom
                        positionU: (1 - scaleU) / 2
                        positionV: (1 - scaleV) / 2
                    }
                }
            }
        }
    }

    component WorldPet: Node {
        id: petAnchor
        required property var pet
        visible: !!pet && !world.hypnotised
        opacity: 1 - world.blindness * .92
        readonly property var helper: Pets.spec(petAnchor.pet ? petAnchor.pet.id : "crow")
        readonly property real flash: { world.revision; return petAnchor.pet ? petAnchor.pet.flash : 0 }
        readonly property var gesture: Pets.attackPose(helper.id, world.motion ? flash : 0)
        readonly property var flight:{
            world.revision
            return pet ? Pets.flight(pet,world.elapsed,world.motion) : {lane:0,elevation:0,depth:900,pitch:0,yaw:0,bank:0}
        }
        eulerRotation: {
            world.revision
            const side = Rules.front(petAnchor.pet ? petAnchor.pet.front : "front")
            return Qt.vector3d(side.pitch, side.yaw, 0)
        }
        PetModel {
            helper: petAnchor.helper
            phase: world.elapsed
            strike: petAnchor.flash
            resting: { world.revision; return petAnchor.pet ? petAnchor.pet.resting > 0 : false }
            animate: world.motion
            chargeProgress:{
                world.revision
                const pet=petAnchor.pet
                return pet?.chargePending && !pet.resting ? 1-pet.chargeLeft/Math.max(.1,pet.chargeLength) : 0
            }
            chargedFlash:{world.revision;return petAnchor.pet?.chargedFlash || 0}
            x:petAnchor.flight.lane
            y:petAnchor.flight.elevation
            z:-petAnchor.flight.depth-petAnchor.gesture[3]
            eulerRotation:Qt.vector3d(petAnchor.gesture[0]+petAnchor.flight.pitch,
                petAnchor.gesture[1]+petAnchor.flight.yaw,petAnchor.gesture[2]+petAnchor.flight.bank)
        }
        Repeater3D {
            model: petAnchor.helper.form === "bat" || petAnchor.helper.form === "chicken" ? 3 : 5
            delegate: Model {
                required property int index
                readonly property real blend: (index + 1) / 6
                visible: petAnchor.flash > 0
                opacity: Math.min(1, petAnchor.flash * 3)
                source: "#Sphere"
                scale: Qt.vector3d(.045, .045, .045)
                position: {
                    world.revision
                    const pet = petAnchor.pet
                    if (!pet)
                        return Qt.vector3d(0, 0, 0)
                    return Qt.vector3d(pet.lane + (pet.aimLane - pet.lane) * blend,
                        pet.elevation + (pet.aimElevation - pet.elevation) * blend,
                        -pet.depth + (pet.depth - pet.aimDepth) * blend)
                }
                materials: PrincipledMaterial {
                    baseColor: {
                        world.revision
                        return petAnchor.pet && petAnchor.pet.hostile ? "#ff536e" : petAnchor.helper.accent
                    }
                    lighting: PrincipledMaterial.NoLighting
                }
            }
        }
    }

    WorldPet { pet: world.flyingPet }
    WorldPet { pet: world.guestPet }

    ActorRoster { id: enemyList; entries: world.actors }
    ActorRoster { id: boltList; entries: world.bolts }
    ActorRoster { id: giftList; entries: world.gifts }
    ActorRoster { id: smokeList; entries: world.smokes }

    Repeater3D {
        model: world.actors.filter(function(foe) { return foe.fangs })
        delegate: Node {
            id: leviathan
            required property var modelData
            readonly property var enemy: modelData
            visible: { world.revision; return !world.hypnotised && !enemy.waitingBoss }
            eulerRotation: {
                world.revision
                const side = Rules.front(enemy.front)
                return Qt.vector3d(side.pitch,side.yaw,0)
            }
            Repeater3D {
                model: leviathan.enemy.fangs
                delegate: Model {
                    required property var modelData
                    readonly property var tip: { world.revision; return Rules.fangPoint(leviathan.enemy,modelData) }
                    visible: { world.revision; return modelData.hp > 0 && !leviathan.enemy.warp && leviathan.enemy.hp > 0 }
                    objectName: String(modelData.id)
                    pickable: visible
                    source: "#Cone"
                    position: Qt.vector3d(tip.lane,tip.elevation,-tip.depth)
                    scale: Qt.vector3d(.48,.96,.38)
                    eulerRotation.z: 180+modelData.side*9
                    materials: PrincipledMaterial {
                        baseColor: "#efcda9"
                        metalness: .26
                        roughness: .36
                    }
                }
            }
        }
    }

    ProceduralMesh {
        id: shellGeometry
        readonly property var mesh: CutArt.hemisphere(false)
        positions: mesh.positions
        normals: mesh.normals
        indexes: mesh.indexes
    }
    ProceduralMesh {
        id: cutGeometry
        readonly property var mesh: CutArt.hemisphere(true)
        positions: mesh.positions
        normals: mesh.normals
        indexes: mesh.indexes
    }
    ProceduralMesh {
        id: cutWing
        readonly property var mesh: CutArt.wing()
        positions: mesh.positions
        normals: mesh.normals
        indexes: mesh.indexes
    }
    Repeater3D {
        model: { world.revision; return world.hypnotised ? 0 : world.splits.length }
        Node {
            id: splitHost
            required property int index
            readonly property var split: { world.revision; return world.splits[index] || null }
            visible: !!split
            Loader3D {
                active: !!splitHost.split
                sourceComponent: SplitBody3D {
                    piece: splitHost.split
                    hemisphere: shellGeometry
                    seam: cutGeometry
                    wing: cutWing
                    motion: world.motion
                    revision: world.revision
                }
            }
        }
    }
    Repeater3D {
        model: { world.revision; return world.hypnotised ? 0 : world.holes.length }
        Node {
            id: wellHost
            required property int index
            readonly property var well: { world.revision; return world.holes[index] || null }
            Loader3D {
                active: !!wellHost.well
                sourceComponent: BlackHole3D {
                    hole: wellHost.well
                    motion: world.motion
                    revision: world.revision
                }
            }
        }
    }

    Repeater3D {
        model: world.hypnotised ? 0 : world.shatters.length
        delegate: Node {
            id: fragments
            required property int index
            readonly property var event: world.shatters[index] || null
            readonly property real age: { world.revision; return event ? 1 - event.life/event.span : 1 }
            readonly property real spread: event ? event.size * age * 270 : 0
            visible: event && event.front === world.frontId
            eulerRotation: {
                const side = Rules.front(event ? event.front : world.frontId)
                return Qt.vector3d(side.pitch, side.yaw, 0)
            }
            PrincipledMaterial { id: amethyst; baseColor: "#8344b8"; roughness: .19; metalness: .57 }
            PrincipledMaterial { id: shardLight; baseColor: "#b57ff0"; lighting: PrincipledMaterial.NoLighting }
            Repeater3D {
                model: 15
                delegate: Model {
                    required property int index
                    readonly property real angle: index * 2.399
                    readonly property real span: .4 + index % 5 * .15
                    source: "#Cube"
                    position: fragments.event ? Qt.vector3d(
                        fragments.event.lane + Math.cos(angle) * fragments.spread * span,
                        fragments.event.elevation + (Math.sin(angle) * span - fragments.age * .78) * fragments.spread,
                        -fragments.event.depth + Math.sin(index * 4) * fragments.spread * .55) : Qt.vector3d(0,0,0)
                    eulerRotation: Qt.vector3d(index*17+fragments.age*210, index*31-fragments.age*327, index*53+fragments.age*145)
                    scale: Qt.vector3d(.065 + index % 4 * .045, .29 + index % 3 * .09, .065 + index % 2 * .04)
                    opacity: Math.min(1, (1-fragments.age)*2.1)
                    materials: [index%3 ? amethyst : shardLight]
                }
            }
        }
    }

    Repeater3D {
        model: enemyList
        Loader3D {
            id: actorNode
            required property int actorId
            readonly property var enemy: enemyList.records[actorId]
            visible: { world.revision; return !enemy.waitingBoss && (enemy.front === world.frontId
                || world.turnRatio < 1 && enemy.front === world.previousFront) && (!world.hypnotised || enemy.type === "hallucination") }
            active: visible
            sourceComponent: enemy.type === "hasasasa" ? warship : demon
            Component {
                id: demon
                Threat3D {
                    enemy: actorNode.enemy
                    revision:actorNode.visible ? world.revision : 0
                    animate:world.motion && actorNode.visible
                    blindness: world.blindness
                    viewedFront: world.frontId
                    grabId: world.grabId
                }
            }
            Component {
                id: warship
                ShipModel {
                    enemy: actorNode.enemy
                    revision: world.revision
                    animate: world.motion
                    visibility: 1 - world.blindness * .93
                }
            }
        }
    }

    Repeater3D {
        model: smokeList
        Node {
            id: cloud
            required property int actorId
            readonly property var smoke: smokeList.records[actorId]
            readonly property real life: { world.revision; return smoke.life }
            eulerRotation: {
                world.revision
                const side = Rules.front(smoke.front)
                return Qt.vector3d(side.pitch, side.yaw, 0)
            }
            Node {
                position: {
                    world.revision
                    return Qt.vector3d(cloud.smoke.lane, cloud.smoke.elevation || 0, -cloud.smoke.depth + 29)
                }
                Repeater3D {
                    model: 9
                    delegate: Model {
                        required property int index
                        readonly property real plume: world.motion ? Math.sin(world.elapsed * (1.8 + index * .07) + index * 2.39) : .4
                        visible: cloud.life > 0
                        source: "#Sphere"
                        x: Math.cos(index * 2.4) * (77 + index * 9 + plume * 18)
                        y: Math.sin(index * 2.4) * (55 + index * 3)
                        z: index * .5
                        scale: Qt.vector3d(1.86 + plume * .3, 1.45 + plume * .2, .08)
                        opacity: Math.min(.70, cloud.life * .52)
                        materials: PrincipledMaterial {
                            lighting: PrincipledMaterial.NoLighting
                            baseColor: index % 2 ? "#07080e" : "#1b1422"
                        }
                    }
                }
            }
        }
    }

    AmethystGeometry { id:shotCrystal }

    Repeater3D {
        model: boltList
        Node {
            id: projectile
            required property int actorId
            readonly property var bolt: boltList.records[actorId]
            readonly property var point: { world.revision; return Rules.projectilePoint(bolt) }
            readonly property bool shipBolt: bolt.source === "hasasasa"
            visible: { world.revision; return !world.hypnotised && bolt.remaining <= bolt.duration }
            opacity: 1 - world.blindness * .92
            eulerRotation: {
                const location = Rules.front(bolt.front)
                return Qt.vector3d(location.pitch, location.yaw, 0)
            }
            Model {
                visible:!projectile.bolt.bubble
                geometry:projectile.bolt.crystal ? shotCrystal : null
                source: projectile.bolt.crystal ? "" : projectile.bolt.shard || projectile.bolt.sniper || projectile.bolt.element === "freeze" && projectile.shipBolt ? "#Cube"
                    : projectile.bolt.fang || projectile.shipBolt && projectile.bolt.element === "burn" ? "#Cone" : "#Sphere"
                objectName: String(projectile.actorId)
                pickable: { world.revision; return Rules.pickableBolt(projectile.bolt, world.frontId, world.meleeReturn) }
                position: Qt.vector3d(projectile.point.lane, projectile.point.elevation, -projectile.point.depth)
                eulerRotation.z: projectile.bolt.crystal ? (world.motion ? world.elapsed*-325 : 30)
                    : projectile.bolt.shard || projectile.shipBolt || projectile.bolt.fang ? (world.motion ? world.elapsed * 650 : 25) : 0
                scale: bolt.bubble ? Qt.vector3d(1.3,1.3,1.3) : bolt.returning ? Qt.vector3d(.24,.24,1.05)
                    : bolt.fang ? Qt.vector3d(.53,1.05,.45) : bolt.core ? Qt.vector3d(.51, .51, .95) : bolt.slug ? Qt.vector3d(.45,.32,.58)
                    : bolt.crystal ? Qt.vector3d(.43,.58,.40) : bolt.shard ? Qt.vector3d(.35,.12,.64)
                    : bolt.voidShot ? Qt.vector3d(.48,.46,1.15) : bolt.sniper ? Qt.vector3d(.15,.15,1.63)
                    : projectile.shipBolt ? Qt.vector3d(.39,.39,.71)
                    : bolt.hp ? Qt.vector3d(.28, .28, .67) : Qt.vector3d(.17, .17, .64)
                materials: PrincipledMaterial {
                    baseColor: bolt.voidShot ? "#211027" : bolt.color
                    lighting: bolt.crystal ? PrincipledMaterial.FragmentLighting : PrincipledMaterial.NoLighting
                    emissiveFactor:bolt.crystal ? Qt.vector3d(.66,.16,.86) : Qt.vector3d(0,0,0)
                }
                opacity: bolt.bubble ? .53 + Math.sin(world.elapsed*6+projectile.actorId)*.15 : 1
            }
            Loader3D {
                active:!!projectile.bolt.bubble
                position:Qt.vector3d(projectile.point.lane,projectile.point.elevation,-projectile.point.depth)
                sourceComponent:Bubble3D {
                    targetId:projectile.actorId
                    pickable:{world.revision; return Rules.pickableBolt(projectile.bolt,world.frontId,world.meleeReturn)}
                    clock:world.motion ? world.elapsed : 0
                }
            }
        }
    }

    ActorRoster {id:bubbleList; entries:world.bubbleBursts}
    Repeater3D {
        model:bubbleList
        delegate:Node {
            id:foamBurst
            required property int actorId
            readonly property var event:bubbleList.records[actorId]
            visible:event.front === world.frontId || world.turnRatio < 1 && event.front === world.previousFront
            eulerRotation:Qt.vector3d(Rules.front(event.front).pitch,Rules.front(event.front).yaw,0)
            BubbleBlast3D {
                event:foamBurst.event
                revision:world.revision
                position:Qt.vector3d(event.lane,event.elevation,-event.depth)
            }
        }
    }

    Repeater3D {
        model: { world.revision; return world.axes.length }
        delegate: Node {
            id: flight
            required property int index
            readonly property var axe: { world.revision; return world.axes[index] || null }
            readonly property var point: { world.revision; return axe ? Rules.axePoint(axe) : null }
            visible: !!axe
            eulerRotation: {
                const side = Rules.front(axe ? axe.front : world.frontId)
                return Qt.vector3d(side.pitch, side.yaw, 0)
            }
            MeleeRig {
                weaponId: "tomahawk"
                accent: "#eac38a"
                position: flight.point ? Qt.vector3d(flight.point.lane, flight.point.elevation, -flight.point.depth) : Qt.vector3d(0,0,0)
                eulerRotation: Qt.vector3d(flight.point ? flight.point.spin : 0, 32, flight.point ? flight.point.spin * .45 : 0)
                scale: Qt.vector3d(.68,.68,.68)
            }
        }
    }

    Repeater3D {
        model: giftList
        delegate: Node {
            id: pouch
            required property int actorId
            readonly property var gift: giftList.records[actorId]
            visible: !world.hypnotised
            opacity: { world.revision; return Math.min(1, gift.remaining / .72) * (1 - world.blindness * .94) }
            eulerRotation: {
                const location = Rules.front(gift.front)
                return Qt.vector3d(location.pitch, location.yaw, 0)
            }
            Node {
                position: Qt.vector3d(pouch.gift.lane, pouch.gift.elevation ?? -68, -pouch.gift.depth)
                scale: pouch.gift.mega ? Qt.vector3d(1.63, 1.48, 1.63) : Qt.vector3d(1, 1, 1)
                eulerRotation.y: world.motion ? world.elapsed * 44 : 19
                Node {
                    visible: !!pouch.gift.token
                    eulerRotation.y: world.motion ? Math.sin(world.elapsed*3)*28 - world.elapsed*44 : 0
                    Model {
                        source: "#Cylinder"
                        objectName: String(pouch.gift.id)
                        pickable: visible && pouch.gift.token === true
                        eulerRotation.x: 90
                        scale: Qt.vector3d(.66,.115,.66)
                        materials: PrincipledMaterial { baseColor:"#e5ac62"; metalness:.62; roughness:.33 }
                    }
                    Model {
                        source: "#Sphere"
                        z: 8
                        scale: Qt.vector3d(.41,.39,.09)
                        materials: PrincipledMaterial { baseColor:"#3c2230"; lighting:PrincipledMaterial.NoLighting }
                    }
                    Repeater3D {
                        model: [-1,1]
                        delegate: Model {
                            required property int modelData
                            source: "#Sphere"
                            x: modelData * 8
                            y: 3
                            z: 13
                            scale: Qt.vector3d(.092,.094,.036)
                            materials: PrincipledMaterial { baseColor:"#ffd55e"; lighting:PrincipledMaterial.NoLighting }
                        }
                    }
                }
                Node {
                visible: !pouch.gift.token
                Model {
                    objectName: String(pouch.gift.id)
                    source: "#Cube"
                    scale: Qt.vector3d(.84, .82, .70)
                    pickable: true
                    materials: PrincipledMaterial { baseColor: pouch.gift.mega ? "#55326b" : "#93493c"; roughness: .46 }
                }
                Model {
                    objectName: String(pouch.gift.id)
                    y: 38
                    source: "#Cube"
                    scale: Qt.vector3d(.91, .23, .76)
                    pickable: true
                    materials: PrincipledMaterial { baseColor: pouch.gift.mega ? "#ffcf72" : "#914e47"; roughness: .42; metalness:.35 }
                }
                Repeater3D {
                    model: pouch.gift.mega ? 8 : 0
                    delegate: Model {
                        required property int index
                        readonly property real t: world.elapsed*2.1+index*Math.PI*.25
                        source:"#Cube"
                        position:Qt.vector3d(Math.cos(t)*62,Math.sin(t*1.5)*23+16,Math.sin(t)*49)
                        eulerRotation:Qt.vector3d(index*36,t*27,index*54)
                        scale:Qt.vector3d(.072,.072,.072)
                        materials:PrincipledMaterial { baseColor:index%2 ? "#ffd745" : "#df9cff"; lighting:PrincipledMaterial.NoLighting }
                    }
                }
                Model {
                    source: "#Cube"
                    y: 3
                    z: 36
                    scale: Qt.vector3d(.152, .80, .022)
                    materials: PrincipledMaterial { baseColor: "#ffe59a"; lighting: PrincipledMaterial.NoLighting }
                }
                Model {
                    source: "#Cube"
                    y: 16
                    z: 36
                    scale: Qt.vector3d(.82, .13, .022)
                    materials: PrincipledMaterial { baseColor: "#ffe59a"; lighting: PrincipledMaterial.NoLighting }
                }
                Repeater3D {
                    model: [-1, 1]
                    delegate: Model {
                        required property int modelData
                        objectName: String(pouch.gift.id)
                        source: "#Sphere"
                        x: modelData * 16
                        y: 58
                        eulerRotation.z: modelData * -29
                        scale: Qt.vector3d(.30, .135, .18)
                        pickable: true
                        materials: PrincipledMaterial { baseColor: "#fff0a6"; lighting: PrincipledMaterial.NoLighting }
                    }
                }
                }
            }
        }
    }
}

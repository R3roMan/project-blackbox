import QtQuick
import "Rules.js" as Rules
import "Pets.js" as Pets
import "Elements.js" as Elements
import "AttackArt.js" as Attacks
import "CreatureLivery.js" as Livery
import "Optics.js" as Optics
import "AbyssPaint.js" as AbyssPaint

Item {
    id: world

    property var actors: []
    property var bolts: []
    property var axes: []
    property var gifts: []
    property var flyingPet: null
    property var guestPet: null
    property var smokes: []
    property real blindness: 0
    property real elapsed: 0
    property real lungeDepth: 0
    property real lungeLane: 0
    property real magnification: 1
    property point lensCentre: Qt.point(.5,.5)
    property bool motion: true
    property bool portraitMode: false
    property bool silhouette: false
    property string frontId: "front"
    property int revision: 0
    property bool hypnotised: false
    property real meleeReturn: 0

    function projection(lane, elevation, depth) {
        return Optics.project(width,height,lane-lungeLane,elevation,depth-lungeDepth,lensCentre,magnification)
    }

    function actorProjection(enemy) {
        return portraitMode ? projection(0, 0, enemy.depth)
            : projection(Rules.lanePosition(enemy), Rules.elevation(enemy), enemy.depth)
    }

    function pickTargets(x, y) {
        const impacts = []
        if (!hypnotised) {
            for (const enemy of actors) {
                if (!enemy.fangs || enemy.front !== frontId || enemy.warp || enemy.waitingBoss)
                    continue
                for (const fang of enemy.fangs) {
                    if (fang.hp <= 0)
                        continue
                    const point = Rules.fangPoint(enemy,fang)
                    const tip = projection(point.lane,point.elevation,point.depth)
                    if (Math.hypot((x-tip.x)*1.3,y-tip.y) <= Math.max(9,tip.scale*42))
                        impacts.push({id:fang.id,depth:point.depth})
                }
            }
        }
        for (let index = 0; index < figures.count; index += 1) {
            const figure = figures.itemAt(index)
            if (!figure || !figure.visible || figure.enemy.type === "hasasasa" || figure.enemy.hp <= 0
                || figure.enemy.warp > 0)
                continue
            const local = figure.mapFromItem(world, x, y)
            if (local.x >= 0 && local.x < figure.width && local.y >= 0 && local.y < figure.height) {
                impacts.push({ depth:figure.enemy.depth, id:figure.enemy.id })
            }
        }
        for (let index = 0; index < bags.count; index += 1) {
            const bag = bags.itemAt(index)
            if (!bag || !bag.visible)
                continue
            const local = bag.mapFromItem(world, x, y)
            if (local.x >= 0 && local.x < bag.width && local.y >= 0 && local.y < bag.height) {
                impacts.push({ depth:bag.gift.depth, id:bag.gift.id })
            }
        }
        for (let index = 0; index < ships.count; index += 1) {
            const ship = ships.itemAt(index)
            if (!ship || !ship.visible)
                continue
            const local = ship.mapFromItem(world, x, y)
            const part = ship.pick(local.x, local.y)
            if (part) {
                impacts.push({ depth:ship.enemy.depth, id:part })
            }
        }
        for (let index = 0; index < shots.count; index += 1) {
            const shot = shots.itemAt(index)
            if (!shot || !shot.visible || !Rules.pickableBolt(shot.bolt, frontId, meleeReturn))
                continue
            if (Math.hypot(x - shot.projected.x, y - shot.projected.y) < Math.max(7, shot.width / 2)) {
                impacts.push({ depth:shot.depth, id:shot.bolt.id })
            }
        }
        impacts.sort(function(first, second) { return first.depth - second.depth })
        return impacts.map(function(impact) { return impact.id })
    }

    function pickTarget(x, y) {
        return pickTargets(x, y)[0] || 0
    }

    ActorRoster { id: enemyList; entries: world.actors }
    ActorRoster { id: boltList; entries: world.bolts }
    ActorRoster { id: giftList; entries: world.gifts }
    ActorRoster { id: smokeList; entries: world.smokes }

    Repeater {
        model: world.actors.filter(function(foe) { return foe.fangs })
        delegate: Item {
            id: leviathan
            required property var modelData
            anchors.fill: parent
            z: 12
            visible: {
                world.revision
                return !world.hypnotised && !modelData.waitingBoss && modelData.front === world.frontId
                    && modelData.hp > 0 && !modelData.warp
            }
            Repeater {
                model: leviathan.modelData.fangs
                delegate: Rectangle {
                    required property var modelData
                    readonly property var tip: {
                        world.revision
                        const point = Rules.fangPoint(leviathan.modelData,modelData)
                        return world.projection(point.lane,point.elevation,point.depth)
                    }
                    visible: { world.revision; return modelData.hp > 0 }
                    x: tip.x-width*.5; y: tip.y-height*.5
                    width: Math.max(7,tip.scale*43)
                    height: width*1.58
                    radius: width*.42
                    rotation: 20+modelData.side*15
                    gradient: Gradient {
                        GradientStop { position:0; color:"#fff2d6" }
                        GradientStop { position:1; color:"#b88772" }
                    }
                    border.color: "#e3b292"
                }
            }
        }
    }

    Repeater {
        id: bags
        model: giftList
        delegate: Item {
            id: bag
            required property int actorId
            readonly property var gift: giftList.records[actorId]
            readonly property var projected: world.projection(gift.lane, gift.elevation ?? -68, gift.depth)
            visible: gift.front === world.frontId && !world.hypnotised
            opacity: { world.revision; return Math.min(1, gift.remaining / .72) * (1 - world.blindness * .94) }
            width: Math.max(gift.mega ? 72 : 40, (gift.mega ? 165 : 93) * projected.scale)
            height: width * (gift.token ? 1 : 1.12)
            x: projected.x - width / 2
            y: projected.y - height / 2
            z: 2000 - gift.depth

            Rectangle {
                visible: !bag.gift.token
                width: parent.width * .40
                height: parent.height * .34
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                rotation: 45
                color: bag.gift.mega ? "#cf9231" : "#935133"
                border.color: "#fff0a9"
                border.width: 2
            }
            Rectangle {
                width: parent.width
                height: parent.height * (bag.gift.token ? 1 : .76)
                anchors.bottom: parent.bottom
                radius: width * (bag.gift.token ? .5 : bag.gift.mega ? .10 : .30)
                color: bag.gift.token ? "#ab6a40" : bag.gift.mega ? "#3a2052" : "#724331"
                border.color: bag.gift.mega ? "#ffe97b" : "#e8b988"
                border.width: bag.gift.mega ? 4 : 2
                Text {
                    anchors.centerIn: parent
                    text: bag.gift.token ? "☠" : bag.gift.mega ? "◆" : "✦"
                    color: "#fff0a4"
                    font.pixelSize: parent.width * .46
                }
            }
            Repeater {
                model: bag.gift.mega ? 4 : 0
                Rectangle {
                    required property int index
                    readonly property real spin: world.elapsed * 2.6 + index*Math.PI*.5
                    x: bag.width*(.5+.62*Math.cos(spin))
                    y: bag.height*(.53+.43*Math.sin(spin))
                    width: 4+index
                    height: width
                    rotation:45
                    color:index%2 ? "#d89eff" : "#ffe082"
                }
            }
        }
    }

    Repeater {
        id: figures
        model: enemyList

        Canvas {
            id: figure
            required property int actorId
            readonly property var enemy: enemyList.records[actorId]
            readonly property var creature: Rules.enemyTypes[enemy.type]
            readonly property bool alien: creature.role === "alien"
            readonly property bool angel: creature.role === "angel" || !!creature.angel
            readonly property bool shade: enemy.type === "mystery"
            readonly property bool ice: enemy.type === "iceterapus"
            readonly property real countdown: { world.revision; return enemy.fuse || 0 }
            readonly property real dodgeLean: {
                world.revision
                return world.motion && enemy.dodgeAge > 0 ? -Math.sign(enemy.dodgeLaneGoal) * 15 * Math.sin(enemy.dodgeAge / .47 * Math.PI) : 0
            }
            readonly property bool angry: { world.revision; return enemy.anger || false }
            readonly property var pose: Attacks.pose(enemy)
            readonly property real strike: { world.revision; return Attacks.amount(enemy, Rules.charging(enemy), world.motion) }
            readonly property bool crawler: creature.role === "void"
            readonly property bool flashing: { world.revision; return enemy.flash > 0 || Rules.charging(enemy) }
            readonly property bool shielded: { world.revision; return enemy.barrier > 0 }
            readonly property real shatter: { world.revision; return enemy.shatter || 0 }
            readonly property string condition: { world.revision; return Elements.visible(enemy.elements) }
            readonly property real clock: { world.revision; return world.motion ? enemy.age : 0 }
            readonly property bool roaring: { world.revision; return enemy.roar > 0 }
            readonly property bool ghost: { world.revision; return Rules.ghosted(enemy) }
            readonly property real warp: { world.revision; return Rules.warpFraction(enemy) }
            readonly property real flap: {
                world.revision
                return !world.motion || crawler || warp > 0 ? 0 : Math.sin(enemy.age * 10) * 0.11
            }
            readonly property var projected: {
                world.revision
                return world.actorProjection(enemy)
            }
            readonly property bool deepRig: creature.abyss && !shade && !creature.voidBoss
                || ["archfellanus","lalaBubu","skorochiyus","crufixicatus"].includes(enemy.type)
            visible: {
                world.revision
                return !enemy.waitingBoss && enemy.type !== "hasasasa" && enemy.front === world.frontId
                    && (!world.hypnotised || enemy.type === "hallucination")
            }
            opacity: shade || creature.voidBoss ? 1 : 1 - world.blindness * .94
            width: (creature.leviathan ? 342 : crawler ? 185 : enemy.type === "meteor" ? 181 : 300) * projected.scale * Rules.enemySize(enemy)
            height: (creature.leviathan ? 231 : crawler ? 142 : enemy.type === "endme" ? 274 : alien ? 146 : angel ? 231 : 183) * projected.scale * Rules.enemySize(enemy)
            rotation: (world.motion && enemy.type === "mastafangenbus" ? ageDegrees : 0) + strike * pose[1] * .56 + dodgeLean
            scale: 1 + strike * pose[2] / 110
            readonly property real ageDegrees: { world.revision; return enemy.age * 170 }
            x: projected.x - width * 0.5
            y: projected.y - height * (world.portraitMode ? .5 : .52)
            z: { world.revision; return 2000 - enemy.depth }
            onFlashingChanged: requestPaint()
            onStrikeChanged: requestPaint()
            onCountdownChanged: requestPaint()
            onAngryChanged: requestPaint()
            onShieldedChanged: requestPaint()
            onShatterChanged: requestPaint()
            onConditionChanged: requestPaint()
            onClockChanged: if (condition || deepRig || shade || angel || creature.slime || creature.serpent || creature.devour
                || creature.voidBoss || creature.sniper || enemy.type === "gigafinterus") requestPaint()
            onRoaringChanged: requestPaint()
            onGhostChanged: requestPaint()
            onWarpChanged: requestPaint()
            onFlapChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onVisibleChanged: if (visible) requestPaint()

            function polygon(ctx, points, fill, edge) {
                ctx.beginPath()
                ctx.moveTo(points[0], points[1])
                for (let index = 2; index < points.length; index += 2)
                    ctx.lineTo(points[index], points[index + 1])
                ctx.closePath()
                ctx.fillStyle = fill
                ctx.fill()
                if (edge) {
                    ctx.strokeStyle = edge
                    ctx.lineWidth = 0.012
                    ctx.stroke()
                }
            }

            function oval(ctx, x, y, w, h, fill, edge) {
                ctx.beginPath()
                ctx.ellipse(x, y, w, h)
                if (fill) {
                    ctx.fillStyle = fill
                    ctx.fill()
                }
                if (edge) {
                    ctx.strokeStyle = edge
                    ctx.lineWidth = 0.016
                    ctx.stroke()
                }
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.scale(width, height)
                const accent = angry ? "#fd5579" : ghost ? "#b9c0ca" : creature.accent
                const skin = angry ? "#daa3b5" : ghost ? "#858a95" : flashing ? Qt.lighter(creature.skin, 1.60) : creature.skin
                const eye = ghost ? "#d3d7de" : flashing ? Qt.lighter(accent, 1.35) : accent

                if (shielded) {
                    ctx.globalAlpha = 0.35
                    oval(ctx, 0.055, 0.04, 0.89, 0.90, "#41ccf6", "")
                    ctx.globalAlpha = 0.95
                    oval(ctx, 0.055, 0.04, 0.89, 0.90, "", "#8be8ff")
                }

                if (shatter > 0) {
                    const burst = 1 - shatter / .48
                    ctx.globalAlpha = shatter / .48
                    for (let i = 0; i < 8; i += 1) {
                        const angle = i * Math.PI / 4
                        const x = .5 + Math.cos(angle) * (.32 + burst * .21)
                        const y = .5 + Math.sin(angle) * (.38 + burst * .22)
                        polygon(ctx, [x - .045, y + .04, x + .035, y + .035, x + .015, y - .056], "#91dfff", "#bdedff")
                    }
                }
                ctx.globalAlpha = Rules.materialization(enemy) * (ghost ? .35 : 1)
                if (enemy.type === "gigafinterus") {
                    for (let i = 5; i >= 0; i -= 1) {
                        const bend = Math.sin(clock * 4.4 - i * .4) * (.028 + i * .011)
                        oval(ctx, .57 + i * .047 + bend, .62 + i * .037, .19 - i * .023, .20 - i * .025,
                            Qt.darker(skin, 1.16), accent)
                    }
                }
                if (!deepRig && !crawler && !angel && !shade && !creature.battlestar && !creature.skeleton && !["meteor", "jon", "claptrap"].includes(enemy.type)) {
                    const points = [0.45, 0.48, 0.32, 0.26 - flap * 0.65, 0.03, 0.14 - flap,
                        0.08, 0.57 - flap * 0.65, 0.18, 0.47 - flap * 0.55, 0.23, 0.69 - flap * 0.3,
                        0.31, 0.55, 0.37, 0.75, 0.46, 0.61]
                    const mirror = points.map(function(value, index) { return index % 2 === 0 ? 1 - value : value })
                    polygon(ctx, points, Qt.darker(skin, 1.34), accent)
                    polygon(ctx, mirror, Qt.darker(skin, 1.34), accent)
                }
                if (creature.trainer || creature.sprayer) {
                    const teacher=!!creature.trainer
                    const hide=teacher ? (angry ? "#bc982d" : "#bdb059") : "#7d777d"
                    oval(ctx,.20,.06,.60,.89,hide,"#332630")
                    for(let i=0;i<(teacher ? 9 : 16);i++) {
                        const angle=i*2.3999
                        oval(ctx,.48+Math.cos(angle)*.22,.48+Math.sin(angle)*.32,teacher ? .20 : .07,teacher ? .017 : .042,"#494038","")
                    }
                    for(let i=0;i<3;i++) oval(ctx,.33+i*.025,.36+i*.075,.34-i*.05,.12,hide,"#756249")
                    for(const side of [-1,1]) {
                        oval(ctx,.48+side*(teacher ? .055 : .11),.23,teacher ? .032 : .07,.06,"#f2d77e","")
                        oval(ctx,.49+side*(teacher ? .055 : .11),.25,.014,.030,"#16121c","")
                    }
                    oval(ctx,.36,.36,.29,enemy.sprayLeft>0 || enemy.trainingMolt>0 && enemy.trainingMolt<1 ? .20 : .043,"#24121e","")
                    if (enemy.sprayLeft>0 || enemy.trainingMolt>0 && enemy.trainingMolt<1) {
                        for(let i=0;i<14;i++) {const t=(clock*1.2+i/14)%1;oval(ctx,.48+Math.sin(clock*3+i*.3)*t*.24,.49+t*.4,.02+t*.015,.025,teacher ? "#8dba32" : "#e4ca32","")}
                    }
                } else if (creature.skeleton) {
                    const jaw = enemy.beamWarning > 0 || enemy.beamLeft > 0 ? .11 : .03
                    for (const side of [-1, 1]) {
                        polygon(ctx, [.50,.49,.50+side*.44,.15,.50+side*.37,.38,.50+side*.39,.60,.50+side*.28,.50,.50+side*.20,.75],
                            "#817161", "#c1a882")
                        for (let i = 0; i < 3; i += 1) {
                            const x = .50+side*(.24+i*.067)
                            polygon(ctx, [x,.46-i*.072,x+side*.045,.73-i*.050,x+side*.022,.48-i*.049], "#e0c698", "")
                        }
                    }
                    polygon(ctx, [.34,.32,.38,.17,.61,.17,.66,.31,.60,.49,.40,.49], "#aa9c89", "#eedcba")
                    polygon(ctx, [.39,.44,.61,.44,.59,.54+jaw,.43,.54+jaw], "#b6a18a", "#ead6b3")
                    oval(ctx,.423,.436,.154,jaw,"#3c2731","")
                    for (const side of [-1, 1]) {
                        const x = .5+side*.067
                        oval(ctx,x-.038,.293,.076,.072,"#312630","")
                        polygon(ctx,[x-.024,.328,x,.301,x+.024,.328,x,.355], "#ffdc49", "#fff1ae")
                    }
                    for (let i = 0; i < 4; i += 1)
                        oval(ctx,.37+i*.025,.61+i*.049,.26-i*.05,.042, "#d6be9d", "#645052")
                } else if (creature.battlestar) {
                    for (const side of [-1, 1]) {
                        polygon(ctx, [.50,.50,.50+side*.28,.08,.50+side*.47,.24,.50+side*.44,.78,.50+side*.22,.68], "#141322", "#7c3343")
                        polygon(ctx, [.50+side*.25,.26,.50+side*.40,.44,.50+side*.34,.51,.50+side*.19,.40], "#9e2940", "")
                    }
                    polygon(ctx, [.50,.07,.69,.40,.63,.77,.50,.96,.37,.77,.31,.40], "#252133", "#b33d53")
                    polygon(ctx, [.41,.48,.59,.48,.55,.72,.45,.72], "#4f2539", "#a8394c")
                    oval(ctx, .465,.52,.07,.122, flashing ? "#fff3cc" : "#ff425f", "#fe6785")
                    for (let i = 0; i < 5; i += 1)
                        oval(ctx, .393 + i * .046,.775,.024,.036, "#e63754", "")
                } else if (creature.slime) {
                    const horned = creature.role === "boss"
                    const gape = Math.max(Math.max(0, strike), flashing ? .48 : 0)
                    const sheen = ctx.createLinearGradient(.2, .24, .83, .95)
                    sheen.addColorStop(0, Qt.lighter(skin, 1.50))
                    sheen.addColorStop(.48, skin)
                    sheen.addColorStop(1, Qt.darker(skin, 1.68))
                    if (horned) {
                        polygon(ctx, [.23,.36,.16,.13,.23,.17,.34,.27,.35,.41], "#716133", "#c6ae71")
                        polygon(ctx, [.77,.36,.84,.13,.77,.17,.66,.27,.65,.41], "#716133", "#c6ae71")
                    }
                    oval(ctx, .154,.29,.692,.595,sheen,"#b5d761")
                    oval(ctx, .224,.26,.552,.31,sheen,"")
                    oval(ctx, .409,.278,.182,.145,eye,"#a8d94b")
                    oval(ctx, .477,.292,.048,.119,"#251e13","")
                    oval(ctx, .467,.303,.020,.023,"#fff8d0","")
                    oval(ctx, .276,.476,.448,.141 + gape * .17,"#161d0d","#a0b54c")
                    for (let i = 0; i < (horned ? 7 : 3); i += 1) {
                        const x = .314 + i * (horned ? .057 : .13)
                        polygon(ctx, [x,.492,x+.038,.492,x+.018,.535+(i%2)*.026], "#d7c181", "")
                    }
                    for (let i = 0; i < 8; i += 1) {
                        const age = (clock * (.65 + i % 3 * .12) + i * .41) % 1
                        const x = .23 + i * .07
                        oval(ctx, x,.68 + age * .21,.024,.054 + age * .035, "#a9d95a", "")
                        oval(ctx, x+.006,.69 + age * .21,.007,.022, "#e4f794", "")
                    }
                } else if (enemy.type === "meteor") {
                    polygon(ctx, [.06,.09,.47,.26,.84,.12,.94,.58,.69,.70,.59,.91,.24,.78,.14,.44], "#f99460", "#f5d783")
                    polygon(ctx, [.17,.34,.38,.14,.64,.23,.84,.48,.71,.77,.52,.89,.26,.75,.10,.57], "#514050", "#ff9c6b")
                    polygon(ctx, [.23,.46,.41,.24,.55,.40,.47,.64,.68,.73,.32,.74], "#875451", "#ef884d")
                } else if (shade) {
                    for (let i = 0; i < 7; i += 1) {
                        const phase = Math.sin(clock * 7 - i * .94) * (.07 + Math.abs(strike) * .05)
                        const tip = .08 + i * .126
                        polygon(ctx, [.36,.37,.65,.42,tip + phase,.82,tip,.99,tip - .04,.75], "#130f23", "#70538e")
                    }
                    oval(ctx, .27,.15,.46,.67,"#0c0b1e","#a685bc")
                    oval(ctx, .362,.34,.10,.099,eye,"")
                    oval(ctx, .532,.34,.105,.099,eye,"")
                } else if (angel) {
                    oval(ctx, .265,.037,.47,.128,"","#a48baf")
                    oval(ctx, .277,.048,.446,.106,"","#211423")
                    for (const side of [-1, 1]) {
                        polygon(ctx, [.5,.43,.5+side*.37,.20,.5+side*.47,.29,.5+side*.34,.56,.5+side*.20,.67],
                            side > 0 ? "#b2a9aa" : "#221c2c", accent)
                    }
                    polygon(ctx, [.38,.34,.62,.34,.82,.88,.63,.94,.50,.89,.37,.94,.18,.88], skin, accent)
                    polygon(ctx, [.43,.42,.57,.43,.58,.88,.50,.84,.43,.88], "#99929b", "#25222e")
                    oval(ctx, .375,.19,.25,.32,enemy.type === "jos" ? skin : "#1b1825",accent)
                    for (const side of [-1, 1]) {
                        const x = .5+side*.086
                        oval(ctx, x - .032,.28,.064,.058,eye,"")
                        if (enemy.type === "jos") {
                            oval(ctx, x - .014,.31 + (clock % .47) * .19,.029,.057,"#7ea6c6","")
                            polygon(ctx, [.5+side*.22,.42,.5+side*.19,.68,x,.34,x-side*.058,.27,.5+side*.14,.31], skin, accent)
                        } else {
                            polygon(ctx, [.5+side*.19,.43,.5+side*.25,.60,.5+side*(.36-strike*.24),.70-strike*.13,
                                .5+side*(.28-strike*.24),.75-strike*.13,.5+side*.16,.61], skin, accent)
                        }
                    }
                    if (enemy.type === "seraphijus") {
                        ctx.fillStyle = "#c2ab94"
                        ctx.fillRect(.352,.503,.296,.225)
                        ctx.fillStyle = "#221822"
                        ctx.fillRect(.367,.515,.266,.196)
                        for (let i = 0; i < 14; i += 1) {
                            const part = Attacks.segments[i % 7]
                            const width = part[2] * .073
                            const height = part[3] * .073
                            const x = .5 + (i < 7 ? -.061 : .061) + part[0] * .073
                            const y = .61 + part[1] * .073
                            ctx.fillStyle = Attacks.countdownSegment(countdown, i) ? (countdown <= 4 ? "#ff8587" : "#ffe3b0") : "#594349"
                            ctx.fillRect(x - width / 2, y - height / 2, width, height)
                        }
                    }
                    if (enemy.type === "lucifoverus") {
                        for (let i = 0; i < 14; i += 1) {
                            const orbit = i * 2.399 + clock * (1 + i % 3 * .24)
                            const x = .50 + Math.cos(orbit) * (.29 + i % 4 * .04)
                            const y = .50 + Math.sin(orbit) * (.25 + i % 5 * .04)
                            const size = .012 + .008 * Math.abs(Math.sin(clock * 5 + i * 2.3))
                            polygon(ctx, [x-size,y,x,y-size*1.5,x+size,y,x,y+size*1.5], i % 3 ? "#fa4772" : "#ffc37d", "")
                        }
                        if (enemy.recover <= 0 && enemy.warp <= 0 && enemy.depth > creature.reach) {
                            polygon(ctx, [.82,.68,.85,.71,.61,.58,.57,.54], "#9d735d", "#1a1523")
                            polygon(ctx, [.48,.57,.43,.49,.52,.53,.53,.46,.60,.53,.66,.49,.67,.55,.60,.61], "#f1c992", accent)
                        } else {
                            const lean = Math.abs(strike) * .26
                            polygon(ctx, [.76-lean,.79,.79-lean,.80,.79,.24,.76,.24], "#ad9d9d", "#1a1523")
                            polygon(ctx, [.67,.31,.71,.11,.73,.24,.76,.24,.77,.067,.80,.24,.83,.24,.85,.11,.88,.31], "#e9d9c2", accent)
                        }
                    }
                } else if (enemy.type === "jon" || enemy.type === "claptrap") {
                    if (enemy.type === "jon") {
                        polygon(ctx, [.48,.11,.56,.20,.61,.30,.95,.58,.91,.73,.62,.66,
                            .61,.91,.39,.91,.38,.66,.09,.73,.05,.58,.39,.30], skin, accent)
                    } else {
                        oval(ctx, .06,.37,.88,.43,skin, accent)
                        for (let i = 0; i < 6; i += 1) {
                            const x = .14 + i * .132
                            polygon(ctx, [x,.67,x+.069,.67,x+.032,.92- (i%3)*.046], "#78bee1", accent)
                        }
                    }
                    oval(ctx, .33,.22,.34,.44,"#39415c",accent)
                    oval(ctx, .415,.356,.17,.16,eye,"")
                    if (strike > .08)
                        oval(ctx, .46,.63,.08,.11 + strike * .15,eye,"")
                } else if (deepRig) {
                    AbyssPaint.draw(ctx,enemy,skin,accent,clock,Rules.warningProgress(enemy),Rules.lureActive(enemy),Rules.mirrorActive(enemy))
                } else if (creature.voidBoss) {
                    oval(ctx,.26,.19,.48,.69,"#5c121122","")
                    for (let i = 0; i < 18; ++i) {
                        const error = Math.sin(Math.floor(clock*(21+i%4))+i*14.61)
                        ctx.fillStyle = i%5 ? "#b521162d" : "#963e103b"
                        ctx.fillRect(.27 + error*.21,.12+i*.045,.23+i%5*.091,.025+i%3*.013)
                    }
                    for (const side of [-1,1]) {
                        const x = .5 + side*.12
                        oval(ctx,x-.081,.309,.162,.11,"#94fb183a","")
                        oval(ctx,x-.054,.338,.108,.053,flashing ? "#ff9d80" : "#ff395d","")
                    }
                } else if (creature.sniper) {
                    polygon(ctx,[.28,.30,.56,.16,.69,.38,.66,.69,.53,.81,.26,.67,.21,.49],"#374a5c","#8491ac")
                    polygon(ctx,[.14,.46,.29,.42,.34,.57,.29,.71,.18,.75],"#223049","#ac8b68")
                    polygon(ctx,[.56,.46,.83,.36,.96,.37,.95,.44,.73,.59,.54,.63],"#263143","#8395af")
                    ctx.fillStyle = "#aa988c"
                    ctx.fillRect(.34,.095,.019,.23)
                    oval(ctx,.33,.074,.047,.062,"#ff705c","")
                    oval(ctx,.30,.29,.30,.19,"#182634","#6c7f97")
                    ctx.fillStyle = flashing ? "#fff8bb" : "#fe7363"
                    ctx.fillRect(.329,.353,.234,.037)
                    ctx.fillRect(.91,.396,.048,.027)
                    for (const side of [-1,1])
                        polygon(ctx,[.5+side*.21,.67,.5+side*.14,.68,.5+side*.195,.89+Math.sin(clock*16+side)*.028],"#f0945f","")
                } else if (creature.devour) {
                    const yaw = (enemy.feedYaw || 0)*Math.PI/180
                    const opening = enemy.feed ? Math.min(1,Math.sin(Math.PI*enemy.feed.time/1.02)) : Math.abs(strike)
                    oval(ctx,.21,.33,.58,.54,skin,accent)
                    for (const side of [-1,1])
                        polygon(ctx,[.5+side*.10,.47,.5+side*.38,.35,.5+side*.31,.61,.5+side*.23,.66],"#773147","#281e28")
                    for (let i=0;i<22;++i) {
                        const angle=i*2.3999
                        const x=.50+Math.cos(angle)*.27
                        const y=.49+Math.sin(angle)*.31
                        polygon(ctx,[x-.025,y+.035,x+.03,y+.030,x+Math.cos(angle)*.054,y-.043],"#332833","")
                    }
                    if (Math.cos(yaw) > -.12) {
                        const offset = Math.sin(yaw)*.12
                        oval(ctx,.26+offset,.31,.48,.31+opening*.22,"#711f38","#b35362")
                        oval(ctx,.31+offset,.37,.38,.20+opening*.22,"#220b16","")
                        for (let i=0;i<9;++i) {
                            const x=.329+offset+i*.039
                            polygon(ctx,[x,.391,x+.025,.381,x+.010,.471+(i%3)*.017],"#edd0a0","")
                            polygon(ctx,[x,.55+opening*.18,x+.031,.55+opening*.18,x+.019,.50+opening*.18],"#d9a76e","")
                        }
                        oval(ctx,.435+offset,.201,.13,.11,enemy.feedingHeal ? "#c4f791" : eye,"")
                        oval(ctx,.477+offset,.218,.046,.081,"#261620","")
                    }
                } else if (creature.serpent) {
                    const sway = world.motion ? Math.sin(clock*4.1)*.035 : 0
                    for (let i = 0; i < 13; ++i) {
                        const angle = i * Math.PI * 2/13
                        oval(ctx,.38+Math.sin(angle)*.25,.68+Math.cos(angle)*.095,.24,.18,
                            i%3 ? "#2b4533" : "#547453","#172b22")
                    }
                    for (let i = 0; i < 7; ++i)
                        oval(ctx,.393+Math.sin(i*.76)*.067+sway*(6-i)/6,.31+i*.058,.20,.17,
                            i%2 ? "#324a38" : "#426348","#182c24")
                    const jaw = Math.max(0,strike)*.18
                    polygon(ctx,[.30+sway,.21,.40+sway,.18,.45+sway,.07,.54+sway,.11,
                        .59+sway,.22,.68+sway,.23,.65+sway,.38,.50+sway,.44+jaw,.34+sway,.36],"#263e31","#789c6f")
                    oval(ctx,.36+sway,.29,.29,.06+jaw,"#181c21","#41553b")
                    for (const side of [-1,1]) {
                        const x = .5 + side*.079 + sway
                        oval(ctx,x-.026,.235,.055,.038,flashing ? "#f4dcff" : "#b4fd6f","")
                        polygon(ctx,[x-.021,.32,x+.024,.32,x,.377+jaw*.50],"#dfd7a8","")
                    }
                } else if (creature.triad) {
                    oval(ctx,.27,.26,.46,.46,"#282735","#adb0c2")
                    for (const side of [-1,1]) {
                        const inset = Math.abs(strike) * .032
                        const x = .5 + side * (.29 - inset)
                        polygon(ctx,[x-.067,.21,x+.067,.21,x+.067,.67,x-side*.047,.79,
                            x-side*.18,.79,x-side*.18,.65,x-.067,.65],"#adb2bc","#282639")
                        ctx.fillStyle = flashing ? "#fff2ff" : "#bd8cff"
                        ctx.fillRect(x-.071,.19,.142,.11)
                        ctx.fillStyle = "#6c5187"
                        for (let i = 0; i < 4; ++i)
                            ctx.fillRect(x-.071,.36+i*.065,.142,.018)
                    }
                    oval(ctx,.348,.335,.304,.25,flashing ? "#fff8ff" : "#d7abff","#f8e6ff")
                    oval(ctx,.472,.366,.056,.18,"#342942","")
                } else if (alien) {
                    polygon(ctx, [0.245, 0.43, 0.33, 0.24, 0.50, 0.18, 0.67, 0.24, 0.755, 0.43,
                        0.72, 0.64, 0.60, 0.83, 0.40, 0.83, 0.28, 0.64], skin, accent)
                    oval(ctx, 0.365, 0.285, 0.27, 0.23, eye, "")
                    oval(ctx, 0.466, 0.314, 0.068, 0.172, "#162530", "")
                    oval(ctx, 0.386, 0.56, 0.228, 0.15, "#191926", "#7d7689")
                    ctx.fillStyle = "#f5dcc1"
                    ctx.fillRect(0.445, 0.57, 0.035, 0.029)
                    ctx.fillRect(0.52, 0.57, 0.035, 0.029)
                    if (enemy.type === "mothergalian") {
                        oval(ctx, .25, .71, .17, .17, "#603350", accent)
                        oval(ctx, .43, .74, .16, .17, "#603350", accent)
                        oval(ctx, .60, .69, .17, .17, "#603350", accent)
                    }
                } else if (crawler) {
                    polygon(ctx, [0.04, 0.8, 0.2, 0.38, 0.32, 0.27, 0.5, 0.09, 0.68, 0.27,
                        0.8, 0.38, 0.96, 0.8, 0.73, 0.68, 0.62, 0.91, 0.38, 0.91, 0.27, 0.68],
                        skin, accent)
                    oval(ctx, 0.30, 0.28, 0.40, 0.42, "", "#e8baff")
                    polygon(ctx, [0.5, 0.32, 0.65, 0.49, 0.5, 0.66, 0.35, 0.49], eye, "#fff1ff")
                } else {
                    polygon(ctx, [0.245, 0.53, 0.27, 0.39, 0.35, 0.32, 0.32, 0.13, 0.425, 0.25,
                        0.575, 0.25, 0.68, 0.13, 0.65, 0.32, 0.73, 0.39, 0.755, 0.53,
                        0.71, 0.76, 0.61, 0.86, 0.50, 0.925, 0.39, 0.86, 0.29, 0.76],
                        skin, accent)
                    polygon(ctx, [0.355, 0.36, 0.5, 0.258, 0.645, 0.36, 0.58, 0.61, 0.42, 0.61],
                        ghost ? "#a1a5ad" : Qt.lighter(skin, 1.26), "")
                    if (ice) {
                        for (let i = 0; i < 15; i += 1) {
                            const angle = i * 2.4
                            const x = .50+Math.cos(angle)*.23
                            const y = .54+Math.sin(angle)*.30
                            polygon(ctx, [x-.06,y,x+.06,y,x+.041,y+.101], "#e6f3fa", "")
                        }
                    }
                    if (enemy.type === "nindumipus") {
                        for (const side of [-1, 1]) {
                            for (let i=0; i<3; i += 1) {
                                const x = .5 + side * (.19 + i * .037 - strike * .13)
                                polygon(ctx, [x,.66,x + side*.09,.57-strike*.25,x + side*.045,.73], "#c7daea", "#ffffff")
                            }
                        }
                    }
                    if (creature.role === "boss")
                        polygon(ctx, [0.455, .245, .50, .04, .545, .245], accent, "#fff2b0")
                    if (enemy.type === "capablancamus") {
                        polygon(ctx,[.31,.31,.31,.19,.38,.27,.40,.14,.46,.26,.50,.087,.54,.26,
                            .60,.14,.62,.27,.69,.19,.69,.31,.59,.35,.41,.35],"#b17746","#ffdfa5")
                        for (const side of [-1,1])
                            polygon(ctx,[.5+side*.24,.68,.5+side*.46,.34-strike*.16,.5+side*.37,.70],
                                "#958f98","#f3d0a6")
                    }
                    oval(ctx,.347,.289,.306,.186,eye,"")
                    oval(ctx,.464,.308,.073,.145,"#20151f","")
                    if (enemy.type === "gigafinterus") {
                        oval(ctx, .31, .46, .38, .25, "#24141f", accent)
                        for (let i = 0; i < 5; i += 1) {
                            const tooth = .34 + i * .068
                            polygon(ctx, [tooth,.489,tooth+.048,.487,tooth+.025,.571], "#ffe6bd", "")
                        }
                    } else if (enemy.type === "zadrrimus") {
                        oval(ctx, .32, .442, .36, .34, "#211021", "#ef7eba")
                        for (let i = 0; i < 5; i += 1) {
                            const tooth = .35 + i * .061
                            polygon(ctx, [tooth, .492, tooth + .051, .495, tooth + .021, .599], "#ffe4bf", "")
                            polygon(ctx, [tooth, .713, tooth + .048, .713, tooth + .027, .636], "#ffe4bf", "")
                        }
                    } else if (enemy.type === "rerogorubus") {
                        oval(ctx, .354, .435, .292, .18, "#211628", accent)
                        const tongue = .18 + .09 * Math.abs(flap)
                        oval(ctx, .454 + flap * .42, .53, .102, tongue + .12, "#e96e8e", "#ffaeaf")
                        ctx.fillStyle = "#f8debe"
                        ctx.fillRect(.38, .477, .052, .043)
                        ctx.fillRect(.57, .477, .052, .043)
                    } else {
                        ctx.save()
                        if (Livery.bellyMaws.includes(enemy.type)) {
                            ctx.translate(.5,.71)
                            ctx.scale(1.48,1.38)
                            ctx.translate(-.5,-.50)
                        }
                        const gape = Math.max(0,strike)*pose[3]
                        oval(ctx,.351,.50,.298,.063+gape*.72,"#28131d","#c6937c")
                        oval(ctx,.342,.56+gape*.55,.32,.052,Qt.lighter(skin,1.20),"#c6937c")
                        ctx.fillStyle = ghost ? "#c5c6cc" : "#f8debe"
                        for (let i=0; i<4; ++i) {
                            ctx.fillRect(.388+i*.056,.505,.027,.030)
                            ctx.fillRect(.385+i*.057,.56+gape*.55,.027,.029)
                        }
                        ctx.restore()
                    }
                }

                const armor = Livery.details[enemy.type]
                if (armor) {
                    const step = armor[1] * .0025
                    for (let i = 0; i < armor[0]; i += 1) {
                        const offset = i - (armor[0] - 1) * .5
                        const x = .50 + offset * step
                        const y = .67 + Math.abs(offset) * .017 + armor[3] * .0017
                        const length = armor[2] * .00135 + .018
                        if (armor[4] === "rib")
                            oval(ctx,x-.015,y,.030,length,Qt.lighter(skin,1.28),"")
                        else if (armor[4] === "gem")
                            polygon(ctx,[x-.018,y,x,y-.017,x+.019,y,x,y+length],Qt.darker(accent,1.30),"")
                        else
                            polygon(ctx,[x-.018,y,x+.021,y,x+offset*.008,y+length],Qt.lighter(skin,1.31),"")
                    }
                }
                if (enemy.type === "gendoustagus") {
                    oval(ctx, .407,.566,.186,.235,"#77418c",accent)
                    oval(ctx, .435,.590,.130,.133,"#f4deee","")
                    ctx.fillStyle = "#f4deee"
                    ctx.fillRect(.457,.674,.086,.064)
                    oval(ctx, .453,.63,.033,.043,"#23182a","")
                    oval(ctx, .513,.63,.033,.043,"#23182a","")
                    polygon(ctx, [.5,.671,.489,.689,.511,.689], "#23182a", "")
                    ctx.fillStyle = "#23182a"
                    for (let i = 0; i < 3; i += 1)
                        ctx.fillRect(.476 + i * .023, .716, .006, .023)
                }

                if (condition) {
                    const ring = Elements.kinds[condition].color
                    if (condition === "freeze" && enemy.elements.frozen > 0) {
                        ctx.globalAlpha = .47
                        oval(ctx, .09, .10, .82, .82, "#6eb7ed", "#c5f6ff")
                    }
                    ctx.globalAlpha = .74
                    for (let i = 0; i < 8; i += 1) {
                        const angle = i * .785 + clock * .51
                        const x = .5 + Math.cos(angle) * .40
                        const y = .5 + Math.sin(angle) * .39
                        polygon(ctx, [x-.022,y+.02,x+.026,y+.018,x+.014,y-.049], ring, "")
                    }
                }

                if (warp > 0 && !["liquid","rise","divine","alienArrival"].includes(enemy.warpKind)) {
                    const opening = Math.sin((1 - warp) * Math.PI)
                    const rim = Rules.warpColor(enemy)
                    ctx.globalAlpha = 0.22 + opening * 0.75
                    oval(ctx, 0.28 - opening * 0.20, 0.02, 0.44 + opening * 0.40, 0.94, "", rim)
                    ctx.fillStyle = rim
                    ctx.fillRect(0.487 - opening * 0.021, 0.05, 0.026 + opening * 0.042, 0.89)
                    oval(ctx, 0.12, 0.76, 0.76, 0.16, "", rim)
                }
                ctx.globalAlpha = 1
                if (world.silhouette) {
                    ctx.globalCompositeOperation = "source-in"
                    ctx.fillStyle = "#050407"
                    ctx.fillRect(0,0,1,1)
                }
            }
        }
    }

    Repeater {
        id: ships
        model: enemyList
        ProjectedShip {
            silhouette:world.silhouette
            required property int actorId
            readonly property var record: enemyList.records[actorId]
            enemy: record.type === "hasasasa" ? record : ({ turrets:[], hp:0, warp:0, wreck:0, barrier:0 })
            revision: world.revision
            time: world.motion ? world.elapsed : 0
            visible: { world.revision; return !world.hypnotised && !record.waitingBoss && record.type === "hasasasa" && record.front === world.frontId }
            opacity: 1 - world.blindness * .94
            readonly property var point: {
                world.revision
                return visible ? world.actorProjection(enemy)
                    : { x:0, y:0, scale:0 }
            }
            width: point.scale * 870
            height: point.scale * 430
            x: point.x - width / 2
            y: point.y - height * (world.portraitMode ? .48 : centerLine)
            z: { world.revision; return visible ? 2000 - enemy.depth : 0 }
        }
    }

    Repeater {
        model: smokeList
        Item {
            id: cloud
            required property int actorId
            readonly property var smoke: smokeList.records[actorId]
            readonly property var point: { world.revision; return world.projection(smoke.lane, smoke.elevation, smoke.depth) }
            visible: { world.revision; return smoke.front === world.frontId }
            opacity: { world.revision; return Math.min(.86, smoke.life * .52) }
            x: point.x - width / 2
            y: point.y - height / 2
            width: point.scale * smoke.radius * 2
            height: point.scale * smoke.height
            z: { world.revision; return 2000 - smoke.depth + .5 }
            Repeater {
                model: 12
                Rectangle {
                    required property int index
                    readonly property real swirl: world.motion ? Math.sin(world.elapsed * 2 + index * 2.4) : .3
                    width: parent.width * (.27 + index % 3 * .05)
                    height: parent.height * (.62 + index % 4 * .06)
                    x: (parent.width - width) / 2 + Math.cos(index * 2.4) * parent.width * (.25 + swirl * .04)
                    y: (parent.height - height) / 2 + Math.sin(index * 2.4) * parent.height * .32
                    radius: height * .46
                    color: index % 2 ? "#07070d" : "#171120"
                }
            }
        }
    }

    component FieldPet: Item {
        id: companion
        required property var model
        anchors.fill: parent
        opacity: 1 - world.blindness * .92
        ProjectedPet {
            id: pet
            helper: Pets.spec(companion.model ? companion.model.id : "crow")
            strike: { world.revision; return companion.model ? companion.model.flash : 0 }
            readonly property var gesture: Pets.attackPose(helper.id, world.motion ? strike : 0)
            visible: { world.revision; return !world.hypnotised && !!companion.model && companion.model.front === world.frontId }
            readonly property var point: {
                world.revision
                const model = companion.model
                return model ? world.projection(model.lane, model.elevation + (world.motion ? Math.sin(world.elapsed * 4.8) * 11 : 0),
                    model.depth - gesture[3]) : world.projection(0, 0, 900)
            }
            x: point.x - width * .5
            y: point.y - height * .5
            width: 117 * point.scale
            height: width * .69
            z: { world.revision; return companion.model ? 2000 - companion.model.depth : 0 }
            resting: { world.revision; return companion.model ? companion.model.resting > 0 : false }
            opacity: resting ? .49 : 1
            flap: world.motion && !resting ? Math.sin(world.elapsed * 13) : 0
            rotation: gesture[2] + gesture[1] * .18
        }
        Rectangle {
            readonly property real flash: { world.revision; return companion.model ? companion.model.flash : 0 }
            readonly property var hit: {
                world.revision
                const model = companion.model
                return model ? world.projection(model.aimLane, model.aimElevation, model.aimDepth) : pet.point
            }
            x: pet.point.x
            y: pet.point.y
            height: 2
            width: Math.hypot(hit.x - x, hit.y - y)
            transformOrigin: Item.Left
            rotation: Math.atan2(hit.y - y, hit.x - x) * 180 / Math.PI
            visible: pet.visible && flash > 0
            opacity: flash * 1.65
            color: pet.helper.accent
            z: 2002
        }
    }
    FieldPet { model: world.flyingPet }
    FieldPet { model: world.guestPet }

    Repeater {
        id: shots
        model: boltList
        Rectangle {
            required property int actorId
            readonly property var bolt: boltList.records[actorId]
            readonly property bool launched: { world.revision; return bolt.remaining <= bolt.duration }
            readonly property var point: { world.revision; return Rules.projectilePoint(bolt) }
            readonly property real depth: point.depth
            readonly property var projected: world.projection(point.lane, point.elevation, depth)
            visible: !world.hypnotised && launched && bolt.front === world.frontId
            width: bolt.hp ? Math.max(14, 2 * Rules.boltRadius(bolt) * projected.scale) : (bolt.returning ? 46 : 15) * projected.scale
            z: 2000 - depth
            opacity: (1 - world.blindness * .94) * (bolt.bubble ? .61 : 1)
            height: bolt.slug ? width * .74 : bolt.sniper ? width * .23 : bolt.shard ? width * .43 : width
            radius: bolt.shard || bolt.sniper || bolt.source === "hasasasa" && bolt.element === "freeze" ? 1 : height / 2
            rotation: radius === 1 ? (world.motion ? world.elapsed * 650 : 25) : 0
            x: projected.x - width / 2
            y: projected.y - height / 2
            color: bolt.voidShot ? "#26071f" : bolt.color
            border.color: bolt.voidShot ? "#ec4c85" : bolt.sniper ? "#ffad8b" : "#eefdf3"
            border.width: bolt.voidShot ? 2 : 1
        }
    }

    Repeater {
        model: { world.revision; return world.axes.length }
        delegate: MeleeSprite {
            required property int index
            readonly property var axe: { world.revision; return world.axes[index] || null }
            readonly property var point: { world.revision; return axe ? Rules.axePoint(axe) : null }
            readonly property var pixel: point ? world.projection(point.lane, point.elevation, point.depth) : null
            objectName: "flyingTomahawk"
            weaponId: "tomahawk"
            accent: "#eac38a"
            visible: !!axe && axe.front === world.frontId
            width: pixel ? Math.min(165, 164 * pixel.scale) : 0
            height: width * .59
            x: pixel ? pixel.x - width * .5 : 0
            y: pixel ? pixel.y - height * .5 : 0
            z: point ? 2000 - point.depth : 0
            rotation: point ? point.spin : 0
        }
    }
}

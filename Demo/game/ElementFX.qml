import QtQuick
import "Rules.js" as Rules

Item {
    id: field
    required property var run
    required property int revision
    required property string frontId
    required property Item world
    required property bool active
    required property bool motion
    property real blindness: 0
    property real fog: 0
    readonly property bool sticky: { revision; return active && run.elements.sticky > 0 }
    readonly property bool poisoned: { revision; return active && run.elements.poison > 0 }

    readonly property bool burning: { revision; return active && run.elements.burn > 0 }
    Rectangle {
        objectName: "burnOverlay"
        anchors.fill: parent
        visible: field.burning
        gradient: Gradient {
            GradientStop { position: 0; color: "#46e83f21" }
            GradientStop { position: .68; color: "#00ec5d34" }
            GradientStop { position: 1; color: "#81fe763a" }
        }
    }

    Rectangle {
        objectName: "poisonFog"
        anchors.fill: parent
        visible: field.active && field.fog > 0
        color: "#526b30"
        opacity: field.fog * .38
    }
    Rectangle {
        objectName: "stickyFilm"
        anchors.fill: parent
        visible: field.sticky || field.poisoned
        radius: 19
        border.width: field.sticky ? 7 : 2
        border.color: field.sticky ? "#e0fa77" : "#9ae06c"
        gradient: Gradient {
            GradientStop { position: 0; color: field.sticky ? "#cf507823" : "#65234c1a" }
            GradientStop { position: .31; color: field.sticky ? "#4b5d9427" : "#10234c1a" }
            GradientStop { position: .69; color: field.sticky ? "#38558d1e" : "#0b234c1a" }
            GradientStop { position: 1; color: field.sticky ? "#cb619231" : "#71234c1a" }
        }
        Repeater {
            model: field.sticky ? 12 : 0
            Rectangle {
                required property int index
                x: (index * .083 + .015) * parent.width
                y: 0
                width: 6 + index % 4 * 3
                height: Math.min(parent.height * .17, 12 + index % 5 * 9)
                radius: width * .5
                color: index % 2 ? "#a89ccb46" : "#c4d6eb68"
            }
        }
    }

    EffectCanvas {
        id: particles
        objectName: "elementEffects"
        anchors.fill: parent
        visible: {
            field.revision
            return field.active && !!field.world && (field.burning || field.run.flames.length || field.run.bursts.length || field.run.arcBursts.length
                || field.run.links.some(function(link) { return link.front === field.frontId })
                || field.run.bolts.some(function(bolt) { return bolt.front === field.frontId && bolt.element === "electric" })
                || field.run.venomClouds.length || field.run.elements.frost || field.run.enemies.some(function(enemy) {
                    return enemy.front === field.frontId
                        && (enemy.elements.burn || enemy.elements.frost || enemy.elements.poison || enemy.beamWarning || enemy.beamLeft)
                }))
        }
        onVisibleChanged: if (visible) requestPaint()
        Connections {
            target: field
            function onRevisionChanged() { if (particles.visible) particles.requestPaint() }
        }

        function point(effect) {
            const local = field.world.projection(effect.lane, effect.elevation, effect.depth)
            return { pos:field.world.mapToItem(particles, local.x, local.y), scale:local.scale }
        }

        function conductor(ctx, link, clock) {
            const first = Rules.target(field.run,link.a)
            const second = Rules.target(field.run,link.b)
            if (!first || !second || first.front !== link.front || second.front !== link.front)
                return
            const from = point({ lane:Rules.lanePosition(first),elevation:Rules.elevation(first),depth:first.depth }).pos
            const to = point({ lane:Rules.lanePosition(second),elevation:Rules.elevation(second),depth:second.depth }).pos
            const dx = to.x-from.x
            const dy = to.y-from.y
            const length = Math.max(1,Math.hypot(dx,dy))
            const phase = Math.floor(clock*24) * 1.77
            ctx.beginPath()
            for (let i = 0; i <= 12; ++i) {
                const step = i/12
                const bow = Math.sin(Math.PI*step) * (Math.min(31,length*.21) + Math.sin(i*6.3+phase+first.id)*6.5)
                const x = from.x+dx*step-dy/length*bow
                const y = from.y+dy*step+dx/length*bow
                if (i)
                    ctx.lineTo(x,y)
                else
                    ctx.moveTo(x,y)
            }
            ctx.globalAlpha = (1-field.blindness*.90) * (link.triangle ? .91 : .66)
            ctx.strokeStyle = "#7141d8"
            ctx.lineWidth = 6
            ctx.stroke()
            ctx.strokeStyle = "#b66efc"
            ctx.lineWidth = 3.5
            ctx.stroke()
            ctx.strokeStyle = "#fff4ff"
            ctx.lineWidth = 1.3
            ctx.stroke()
        }

        function lightningBolt(ctx, bolt, clock) {
            if (bolt.front !== field.frontId || bolt.remaining > bolt.duration || bolt.remaining <= 0)
                return
            const shot = Rules.projectilePoint(bolt)
            const head = point(shot).pos
            const end = point({ lane:shot.lane+Math.sign(bolt.lane)*38,elevation:shot.elevation+15,depth:shot.depth+270 }).pos
            const span = Math.max(15,Math.hypot(head.x-end.x,head.y-end.y))
            const drift = Math.min(21,span*.46)
            ctx.beginPath()
            ctx.moveTo(head.x,head.y)
            for (let i = 1; i <= 7; ++i) {
                const step = i/7
                const noise = Math.sin(clock*31+i*4.7+bolt.id) * drift * Math.sin(step*Math.PI)
                ctx.lineTo(head.x+(end.x-head.x)*step+noise,head.y+(end.y-head.y+span*.57)*step)
            }
            ctx.globalAlpha = .90*(1-field.blindness*.88)
            ctx.lineWidth = 6.5
            ctx.strokeStyle = "#9159ee"
            ctx.stroke()
            ctx.lineWidth = 1.9
            ctx.strokeStyle = "#fff1ff"
            ctx.stroke()
        }

        function emberTrails(ctx, centre, size, time, strength) {
            for (let i = 0; i < 8; i += 1) {
                const age = (time * (1.07 + (i%4)*.17) + i*.163)%1
                const x = centre.x + (i/7-.5)*size*.66 + Math.sin(age*8+i)*size*.12
                const y = centre.y + size*.34 - age*size*.65
                const width = size * (.06 + age*.055)
                const top = y - size * (.23 + age*.27 + strength*.034)
                const flame = ctx.createLinearGradient(x,y,x,top)
                flame.addColorStop(0,"#b6fff0a7")
                flame.addColorStop(.30,"#edff933f")
                flame.addColorStop(.68,"#9bf14723")
                flame.addColorStop(1,"#00732922")
                ctx.fillStyle = flame
                ctx.beginPath()
                ctx.moveTo(x-width,y)
                ctx.bezierCurveTo(x-width*1.35,y-size*.14,x+width*.25,top+size*.09,x+width*.34,top)
                ctx.bezierCurveTo(x+width*.86,top+size*.16,x+width*1.18,y-size*.085,x+width,y)
                ctx.closePath()
                ctx.fill()
            }
            for (let i = 0; i < 10; i += 1) {
                const age = (time * (.81 + i % 3 * .11) + i * .197) % 1
                const spread = (i / 9 - .5) * size * .98
                const lift = age * size * (.9 + strength * .13)
                const peak = centre.x + spread + Math.sin(i * 2.29 + time * 6) * age * size * .18
                const start = centre.y + size * .4 - lift * .61
                const end = start - size * (.15 + age * .28)
                const fire = ctx.createLinearGradient(peak, start, peak, end)
                fire.addColorStop(0, Qt.rgba(1, .25 + i % 3 * .08, .12, Math.sin(age * Math.PI) * .53))
                fire.addColorStop(.52, "#ffe19a")
                fire.addColorStop(1, "#00ffa24a")
                ctx.beginPath()
                ctx.moveTo(peak, start)
                ctx.quadraticCurveTo(peak + spread * .26, (start + end) / 2, peak - spread * .20, end)
                ctx.strokeStyle = fire
                ctx.lineWidth = Math.max(1, size * (.048 - age * .018))
                ctx.stroke()
            }
        }

        function iceFractures(ctx, centre, size, time, suspended) {
            const nodes = suspended ? 13 : 8
            for (let i = 0; i < nodes; i += 1) {
                const age = (time * .61 + i * .387) % 1
                const angle = i * 2.4 + time * (suspended ? .18 : .47)
                const x = centre.x + Math.cos(angle) * size * (.37 + age * .31)
                const y = centre.y + Math.sin(angle) * size * (.31 + age * .31)
                const spark = 1.5 + size * (.034 + age * .021)
                ctx.strokeStyle = Qt.rgba(.70, .94, 1, .46 + .43 * Math.sin(age * Math.PI))
                ctx.lineWidth = Math.max(1, size * .012)
                if (suspended) {
                    ctx.beginPath()
                    ctx.moveTo(centre.x + Math.cos(angle) * size * .18, centre.y + Math.sin(angle) * size * .17)
                    ctx.lineTo(x + spark * .23, y - spark)
                    ctx.lineTo(x, y)
                    ctx.stroke()
                }
                ctx.beginPath()
                ctx.moveTo(x, y - spark)
                ctx.lineTo(x + spark * .55, y)
                ctx.lineTo(x, y + spark)
                ctx.lineTo(x - spark * .55, y)
                ctx.closePath()
                ctx.stroke()
            }
        }

        onPaint: {
            const ctx = beginPaint()
            ctx.clearRect(0, 0, width, height)
            if (!field.world || !field.active)
                return
            const clock = field.motion ? field.run.time : .37
            for (const link of field.run.links) {
                if (link.front === field.frontId)
                    conductor(ctx,link,clock)
            }
            for (const bolt of field.run.bolts) {
                if (bolt.element === "electric")
                    lightningBolt(ctx,bolt,clock)
            }
            ctx.globalAlpha = 1
            for (const enemy of field.run.enemies) {
                if (enemy.front !== field.frontId || enemy.warp > 0 || !(enemy.elements.burn || enemy.elements.frost || enemy.elements.poison))
                    continue
                const projected = point({ lane:Rules.lanePosition(enemy), elevation:Rules.elevation(enemy), depth:enemy.depth })
                const size = Math.min(230, 170 * projected.scale * Rules.enemySize(enemy))
                ctx.globalAlpha = (1 - field.blindness * .94) * .81
                if (enemy.elements.burn)
                    emberTrails(ctx, projected.pos, size, clock + enemy.id * .25, enemy.elements.burn)
                else if (enemy.elements.frost)
                    iceFractures(ctx, projected.pos, size, clock + enemy.id * .17, enemy.elements.frozen > 0)
                if (enemy.elements.poison) {
                    ctx.fillStyle = "#b8f478"
                    for (let i = 0; i < 7; i += 1) {
                        const age = (clock * .72 + i * .237) % 1
                        const spread = Math.sin(i * 17.3) * size * .34
                        const x = projected.pos.x + spread + Math.sin(age * 9 + i) * 5
                        const y = projected.pos.y + .37 * size - age * size * .91
                        ctx.globalAlpha = (1 - field.blindness * .94) * (1 - age) * .78
                        ctx.beginPath()
                        ctx.arc(x, y, Math.max(1, size * (.019 + age * .026)), 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
            }
            ctx.globalAlpha = 1

            for (const enemy of field.run.enemies) {
                if (enemy.front !== field.frontId || !(enemy.beamLeft || enemy.beamWarning))
                    continue
                const origin = point({ lane:Rules.lanePosition(enemy), elevation:Rules.elevation(enemy) - 24, depth:enemy.depth - 65 }).pos
                const hot = enemy.beamLeft > 0
                const gold = enemy.type === "skarabatunus"
                ctx.globalAlpha = (1 - field.blindness * .85) * (hot ? .84 : .70)
                ctx.beginPath()
                ctx.moveTo(origin.x, origin.y)
                ctx.lineTo(width * .5, height * .77)
                ctx.strokeStyle = gold ? "#f5ac35" : "#ed254c"
                ctx.lineWidth = hot ? (gold ? 26 : 40) + Math.sin(clock * 56) * 5 : 3
                ctx.stroke()
                ctx.strokeStyle = hot ? "#fff3dd" : gold ? "#ffd984" : "#ff9b9f"
                ctx.lineWidth = hot ? 10 : 1
                ctx.stroke()
            }
            ctx.globalAlpha = 1

            for (const flame of field.run.flames) {
                if (flame.front !== field.frontId)
                    continue
                const from = point(flame).pos
                const age = 1 - flame.remaining / flame.duration
                for (let i = 0; i < 31; i += 1) {
                    const speed = .55 + (i % 7) * .086
                    const t = field.motion ? Math.max(0, (age * 1.9 * speed - i * .024) % 1) : i / 31
                    const cone = Math.sin(i * 15.1 + age * 11) * t
                    const x = from.x + (width * .5 - from.x) * t + cone * width * .21
                    const y = from.y + (height * .58 - from.y) * t + Math.cos(i * 52) * t * height * .14
                    const radius = (10 + 68 * t) * (.45 + (i % 5) * .12)
                    const glow = ctx.createRadialGradient(x, y, radius * .1, x, y, radius)
                    glow.addColorStop(0, i % 3 ? "#ffe57d" : "#ff7344")
                    glow.addColorStop(.49, "#d6ff7b31")
                    glow.addColorStop(1, "#00d34526")
                    ctx.globalAlpha = Math.min(1, flame.remaining * 3) * (.76 + i % 5 * .04)
                    ctx.fillStyle = glow
                    ctx.fillRect(x - radius, y - radius, radius * 2, radius * 2)
                }
            }

            for (const cloud of field.run.venomClouds) {
                if (cloud.front !== field.frontId)
                    continue
                const origin = point(cloud)
                const elapsed = cloud.duration - cloud.remaining
                const life = Math.min(1, cloud.remaining / .60)
                for (let i = 0; i < 21; i += 1) {
                    const angle = i * 2.399 + (field.motion ? clock * .32 : 0)
                    const flow = Math.max(0, Math.min(1, (elapsed - (i % 7) * .080) / (cloud.hostile ? .96 : .55)))
                    if (flow <= 0)
                        continue
                    const spread = cloud.hostile ? width * .36 * flow : cloud.radius * origin.scale * flow
                    const x = origin.pos.x + (cloud.hostile ? (width * .50 - origin.pos.x) * flow : 0)
                        + Math.cos(angle) * spread * (.28 + i % 5 * .14)
                    const y = origin.pos.y + (cloud.hostile ? (height * .51 - origin.pos.y) * flow : 0)
                        + Math.sin(angle) * spread * .53
                    const radius = 8 + (cloud.hostile ? height * .18 : spread * .46) * flow * (.56 + i % 5 * .12)
                    const vapor = ctx.createRadialGradient(x, y, 0, x, y, radius)
                    vapor.addColorStop(0, i % 3 ? "#d0aadb52" : "#d6ddf58b")
                    vapor.addColorStop(.45, i % 3 ? "#9878a445" : "#a49abc62")
                    vapor.addColorStop(1, "#0072a347")
                    ctx.globalAlpha = life * (1 - field.blindness * .82) * (cloud.hostile ? .59 : .46)
                    ctx.fillStyle = vapor
                    ctx.fillRect(x - radius, y - radius, radius * 2, radius * 2)
                }
            }

            for (const burst of field.run.bursts) {
                if (burst.front !== field.frontId)
                    continue
                const projected = point(burst)
                const age = Math.max(0, 1 - burst.life / (burst.span || .61))
                const radius = Math.min(width * .49, 15 + burst.radius * projected.scale * (.22 + age * .72))
                ctx.globalAlpha = 1 - age
                ctx.beginPath()
                ctx.arc(projected.pos.x, projected.pos.y, Math.max(1, radius), 0, Math.PI * 2)
                ctx.lineWidth = 3 + (1 - age) * 9
                ctx.strokeStyle = burst.color || (burst.danger ? "#ff9867" : "#ffd58a")
                ctx.stroke()
                for (let i = 0; i < 15; i += 1) {
                    const angle = i * 2.399
                    ctx.fillStyle = burst.color || (i % 2 ? "#ff9f70" : "#ffdf92")
                    ctx.fillRect(projected.pos.x + Math.cos(angle) * radius * (i % 3 + 2) / 4,
                        projected.pos.y + Math.sin(angle) * radius * (i % 3 + 2) / 4, 4, 4)
                }
            }

            for (const arc of field.run.arcBursts) {
                if (arc.front !== field.frontId || arc.life > arc.span)
                    continue
                const age = 1 - arc.life / arc.span
                const from = point(arc.from).pos
                const to = point(arc.to).pos
                const deltaX = to.x - from.x
                const deltaY = to.y - from.y
                const distance = Math.hypot(deltaX, deltaY) || 1
                const length = field.motion ? Math.min(1, age * 8) : 1
                const charge = .58 + arc.power * .55
                const nodes = []
                const pulse = field.motion ? Math.floor(clock * 40) : .75
                ctx.beginPath()
                for (let i = 0; i <= 9; i += 1) {
                    const segment = i / 9
                    const step = segment * length
                    const shift = Math.sin(i * 32.1 + pulse * 5.7 + arc.hop) * Math.sin(segment * Math.PI)
                        * Math.min(19, 5 + distance * .13) * charge
                    const x = from.x + deltaX * step - deltaY * shift / distance
                    const y = from.y + deltaY * step + deltaX * shift / distance
                    nodes.push(Qt.point(x, y))
                    if (i)
                        ctx.lineTo(x, y)
                    else
                        ctx.moveTo(x, y)
                }
                const alpha = Math.min(1, (1 - age) * 1.54) * (1 - field.blindness * .80)
                ctx.globalAlpha = alpha * .44
                ctx.lineWidth = 14 * charge
                ctx.strokeStyle = "#9345f5"
                ctx.stroke()
                ctx.globalAlpha = alpha * .86
                ctx.lineWidth = 6.5 * charge
                ctx.strokeStyle = "#c377ff"
                ctx.stroke()
                ctx.globalAlpha = alpha
                ctx.lineWidth = 2.2 * charge
                ctx.strokeStyle = "#fff9ff"
                ctx.stroke()
                for (let i = 2; i < 8; i += 2) {
                    const branch = nodes[i]
                    const shift = Math.sin(i * 15.6 + pulse) * 19 * charge
                    ctx.beginPath()
                    ctx.moveTo(branch.x, branch.y)
                    ctx.lineTo(branch.x + shift * .54, branch.y - shift)
                    ctx.lineTo(branch.x + shift * 1.3, branch.y - shift * 1.2)
                    ctx.strokeStyle = i % 4 ? "#f4c1ff" : "#af72ff"
                    ctx.lineWidth = 1.4
                    ctx.stroke()
                }
                if (length >= 1) {
                    const pulseRadius = Math.max(2, (6 + age * 28) * charge)
                    ctx.beginPath()
                    ctx.arc(to.x, to.y, pulseRadius, 0, Math.PI * 2)
                    ctx.strokeStyle = "#dcadff"
                    ctx.lineWidth = 2.3
                    ctx.stroke()
                    for (let i = 0; i < 8; i += 1) {
                        const angle = i * 2.39 + arc.hop
                        const spark = pulseRadius * (1 + i % 3 * .27)
                        ctx.fillStyle = i % 2 ? "#fff3ff" : "#ae6bff"
                        ctx.fillRect(to.x + Math.cos(angle) * spark, to.y + Math.sin(angle) * spark, 3 * charge, 3 * charge)
                    }
                }
            }

            if (field.run.elements.frost) {
                ctx.globalAlpha = .69
                for (let i = 0; i < 12; i += 1) {
                    const fraction = (i * .169 + clock * .34) % 1
                    const edge = i % 2 ? 0 : width
                    const x = edge + (i % 2 ? 1 : -1) * (12 + fraction * 72)
                    const y = (i * 89 + clock * (15 + i % 3 * 9)) % height
                    iceFractures(ctx, Qt.point(x, y), 9 + i % 3 * 4, clock, false)
                }
            }

            if (field.burning) {
                ctx.globalAlpha = .75
                for (let i = 0; i < 24; i += 1) {
                    const fraction = field.motion ? (field.run.time * (.55 + i % 3 * .11) + i * .37) % 1 : (i * .37) % 1
                    const x = (i * 67.7) % width
                    const y = height - fraction * height * .30
                    ctx.fillStyle = i % 2 ? "#ff9d5c" : "#ffe08f"
                    ctx.fillRect(x, y, 2 + i % 4, 2 + i % 6)
                }
            }
        }
    }
}

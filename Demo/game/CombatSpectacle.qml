import QtQuick
import "Rules.js" as Rules
import "Encounters.js" as Encounters
import "CutArt.js" as CutArt
import "Conditions.js" as Weather

EffectCanvas {
    id: field
    required property var run
    required property int revision
    required property string frontId
    required property Item world
    required property bool active
    required property bool motion
    property bool projected: false
    property bool ultra:false
    property color sceneLight:"#fff0db"
    property real darkness:0
    property real obscurity:0

    function litBlood(ink,depth) {
        const color=Qt.color(ink)
        const shade=1-darkness*.46
        const fog=obscurity*(1-Weather.fogVisibility(depth))
        const red=color.r*(.6+.4*sceneLight.r)*shade
        const green=color.g*(.6+.4*sceneLight.g)*shade
        const blue=color.b*(.6+.4*sceneLight.b)*shade
        return Qt.rgba(red*(1-fog)+.46*fog,green*(1-fog)+.49*fog,blue*(1-fog)+.54*fog,color.a)
    }

    readonly property var seals: ({
        humontafagus:{ tint:"#ff6b69", rings:2, vanes:5, spin:1.6, pattern:"teeth" },
        mastafangenbus:{ tint:"#87ffe0", rings:3, vanes:10, spin:-4.9, pattern:"cogs" },
        gigafinterus:{ tint:"#ff9b4f", rings:2, vanes:7, spin:-1.9, pattern:"flames" },
        lucifoverus:{ tint:"#ffe391", rings:4, vanes:5, spin:1.2, pattern:"spires" },
        hasasasa:{ tint:"#8fd4ff", rings:3, vanes:12, spin:3.5, pattern:"signal" },
        stinkaturumus:{ tint:"#c4f465", rings:2, vanes:8, spin:-2.5, pattern:"bubbles" },
        voidGlitch:{ tint:"#ff365f", rings:4, vanes:13, spin:-4.1, pattern:"fracture" },
        reapfast:{ tint:"#90e1ff", rings:3, vanes:12, spin:-1.4, pattern:"bubbles" }
    })
    readonly property var blades: ({
        katana:[.78,.25,1.50], nailclub:[.24,.90,.81], mechasword:[.57,.41,1.32],
        duoknives:[.40,.30,1.42], darksaber:[.67,.28,1.24], chainsaw:[.51,.73,2.0],
        gravhammer:[.64,.96,.88], reaperscythe:[1.19,.41,1.37], tomahawk:[.64,.51,1.12], bayonet:[.20,.40,1.12],
        helltrident:[.21,.66,1.7]
    })
    readonly property var deaths: ({
        humontafagus:{flesh:"#eb6772",spark:"#ffa381",reach:1.25,lift:.83,twist:.18,organs:11,waves:2},
        mastafangenbus:{flesh:"#dd4778",spark:"#89ffee",reach:1.77,lift:.38,twist:2.4,organs:13,waves:3},
        gigafinterus:{flesh:"#dc4533",spark:"#ffd061",reach:1.13,lift:1.67,twist:.71,organs:9,waves:2},
        lucifoverus:{flesh:"#a11935",spark:"#ffee9a",reach:.88,lift:1.55,twist:-1.24,organs:10,waves:4},
        hasasasa:{flesh:"#a04163",spark:"#bedaef",reach:2.01,lift:.54,twist:-.16,organs:18,waves:4},
        stinkaturumus:{flesh:"#638733",spark:"#cce46b",reach:1.59,lift:.94,twist:.41,organs:16,waves:3},
        voidGlitch:{flesh:"#472447",spark:"#f75286",reach:1.48,lift:1.34,twist:1.31,organs:12,waves:5},
        reapfast:{flesh:"#2d243d",spark:"#78ecf6",reach:2.18,lift:1.77,twist:-.86,organs:20,waves:4}
    })

    visible: {
        revision
        return active && !!world && (run.splits.length || run.holes.length
            || run.gore.some(function(event) { return event.front === frontId })
            || run.enemies.some(function(enemy) {
                return enemy.front === frontId && !enemy.waitingBoss && (enemy.warp > 0 || ["Nightmare","Overlord"].includes(Encounters.tier(enemy.type)))
            }))
    }
    onVisibleChanged: if (visible) requestPaint()
    onRevisionChanged: if (visible) requestPaint()

    function project(lane, elevation, depth) {
        const where = world.projection(lane, elevation, depth)
        return { pos:world.mapToItem(field, where.x, where.y), scale:where.scale }
    }

    function eelCharge(ctx, enemy) {
        const anchor = project(Rules.lanePosition(enemy), Rules.elevation(enemy), enemy.depth)
        const reach = Math.max(21,anchor.scale * 84 * Rules.enemySize(enemy))
        const time = motion ? enemy.age : 0
        ctx.save()
        ctx.translate(anchor.pos.x,anchor.pos.y)
        ctx.lineWidth = 1.45
        for (let i = 0; i < 3; ++i) {
            const curve = time * (3 + i) + i * 2.4
            ctx.beginPath()
            for (let j = 0; j < 7; ++j) {
                const angle = curve + j * .22
                const r = reach * (j % 2 ? .94 : 1.17)
                const x = Math.cos(angle)*r
                const y = Math.sin(angle)*r*.70
                if (j === 0)
                    ctx.moveTo(x,y)
                else
                    ctx.lineTo(x,y)
            }
            ctx.strokeStyle = i % 2 ? "#c7e4f778" : "#de8554b9"
            ctx.stroke()
        }
        ctx.restore()
    }

    function pentagram(ctx, radius, rotation) {
        ctx.beginPath()
        for (let i = 0; i <= 5; i += 1) {
            const angle = rotation + i * Math.PI * .8 - Math.PI*.5
            const x = Math.cos(angle)*radius
            const y = Math.sin(angle)*radius
            if (!i)
                ctx.moveTo(x,y)
            else
                ctx.lineTo(x,y)
        }
        ctx.stroke()
    }

    function reveal(ctx, enemy, spec) {
        const floor = project(Rules.lanePosition(enemy), -105, enemy.depth)
        const age = 1 - Rules.warpFraction(enemy)
        const turn = motion ? age * spec.spin : .12
        const radius = Math.max(30, floor.scale * 270 * Rules.enemySize(enemy)) * (.50 + age*.54)
        ctx.save()
        ctx.translate(floor.pos.x, floor.pos.y)
        ctx.scale(1, spec.pattern === "signal" ? .84 : .61)
        ctx.globalAlpha = Math.max(.05, Math.sin(Math.PI*age)) * .95
        ctx.fillStyle = "#97190b1a"
        ctx.beginPath()
        ctx.arc(0,0,radius*1.15,0,Math.PI*2)
        ctx.fill()
        ctx.strokeStyle = spec.tint
        for (let ring = 0; ring < spec.rings; ring += 1) {
            const r = radius * (.67 + ring*.16)
            ctx.beginPath()
            if (spec.pattern === "signal" || spec.pattern === "cogs" || spec.pattern === "fracture") {
                for (let seg = 0; seg < spec.vanes; seg += 1) {
                    const broken = spec.pattern === "fracture" ? .12*Math.sin(age*69+seg*15+ring) : 0
                    const a = turn * (ring%2 ? -1 : 1) + seg*2*Math.PI/spec.vanes + broken
                    ctx.moveTo(Math.cos(a)*r, Math.sin(a)*r)
                    ctx.arc(0,0,r,a,a+Math.PI*1.42/spec.vanes)
                }
            } else {
                ctx.arc(0,0,r,0,Math.PI*2)
            }
            ctx.lineWidth = ring ? 2 : 5
            ctx.stroke()
        }
        ctx.lineWidth = 8
        pentagram(ctx,radius*.76,turn+angleBias(spec.pattern))
        ctx.strokeStyle = "#fff1e8"
        ctx.lineWidth = 2
        pentagram(ctx,radius*.76,turn+angleBias(spec.pattern))
        for (let i = 0; i < spec.vanes; i += 1) {
            const phase = turn + i*2*Math.PI/spec.vanes
            ctx.save()
            ctx.rotate(phase)
            ctx.strokeStyle = spec.tint
            ctx.lineWidth = spec.pattern === "spires" ? 1.7 : 3
            ctx.beginPath()
            if (spec.pattern === "bubbles") {
                ctx.arc(radius*(1.04+.10*Math.sin(age*10+i)),0,4+10*age,0,Math.PI*2)
            } else if (spec.pattern === "fracture") {
                ctx.rect(radius*(1.02+.25*Math.sin(i+age*75)),-5,7+i%5*5,3+i%3*4)
            } else if (spec.pattern === "signal") {
                ctx.rect(radius*1.04,-6,17,12)
            } else if (spec.pattern === "cogs") {
                ctx.moveTo(radius*.94,-7)
                ctx.lineTo(radius*1.17,-7)
                ctx.lineTo(radius*1.17,7)
                ctx.lineTo(radius*.94,7)
            } else {
                const spike = spec.pattern === "spires" ? 1.34 : spec.pattern === "flames" ? 1.26+.13*Math.sin(age*14+i) : 1.23
                ctx.moveTo(radius*.94,-12)
                ctx.lineTo(radius*spike,0)
                ctx.lineTo(radius*.94,12)
            }
            ctx.stroke()
            ctx.restore()
        }
        ctx.restore()
    }

    function angleBias(pattern) {
        return pattern === "flames" ? Math.PI*.5 : pattern === "spires" ? Math.PI : 0
    }

    function spill(ctx, event) {
        const where = project(event.lane,event.elevation,event.depth)
        const point = where.pos
        const progress = 1 - event.life / event.span
        const age = motion ? progress : .23
        const scale = Math.max(8, Math.min(112, where.scale * event.size * 101))
        const arc = blades[event.style] || [.33,.49,1]
        const count=event.crystal ? 28 : event.fatal && ultra ? 13 : event.boss && event.fatal ? 34
            : event.fatal ? 20 : Math.round(7*arc[2])
        const visibility=1-obscurity*(1-Weather.fogVisibility(event.depth))*.68
        const mass = event.boss && event.fatal ? 2.22 : event.fatal ? 1.42 : .70
        ctx.globalAlpha=visibility*Math.min(.86,Math.pow(1-progress,.55))
        for (let i = 0; i < count; i += 1) {
            const seed = event.id * .862 + i * 2.399
            const spread = Math.sin(seed * 11.4)
            const xSpeed = (Math.cos(seed) * arc[0] + spread * .38) * mass
            const ySpeed = Math.sin(seed) * arc[1] * mass
            const x = point.x + xSpeed*scale*(.16 + age*2.9)
            const y = point.y + ySpeed*scale*(.14 + age*1.52) + scale*age*age*mass*1.92
            const r = (event.fatal ? 3.6 : 2.0) + scale*.072 * (i%5) * (1-age) * mass
            const pigment=event.crystal ? i%4===0 ? "#df99ff" : event.tint
                : event.dark ? i%4 ? event.tint : "#2c1937"
                    : i%4===0 ? "#4d1028" : i%3===0 ? "#b23746" : event.tint
            ctx.fillStyle=litBlood(pigment,event.depth)
            ctx.strokeStyle = ctx.fillStyle
            if (event.fatal && i%4 === 0) {
                ctx.beginPath()
                ctx.moveTo(x-r,y-r*.36)
                ctx.lineTo(x+r*.55,y-r*(event.crystal ? 3.2 : 1))
                ctx.lineTo(x+r,y+r*.43)
                ctx.lineTo(x-r*.50,y+r)
                ctx.closePath()
                ctx.fill()
            } else {
                ctx.beginPath()
                ctx.ellipse(x,y,r*.48,r*(.52+age*.42))
                ctx.fill()
            }
            if (i%3 === 1) {
                ctx.beginPath()
                ctx.moveTo(x,y)
                ctx.lineTo(x-xSpeed*r*3,y-r*.74)
                ctx.lineWidth = 1 + r*.26
                ctx.stroke()
            }
        }
        if (event.fatal && !event.crystal) {
            const pool=scale*mass*(.19+age*.62)
            const floor=point.y+scale*(.86+age*.86)
            const puddle=ctx.createRadialGradient(point.x,floor,0,point.x,floor,pool)
            puddle.addColorStop(0,litBlood(event.dark ? "#160b21" : "#591020",event.depth))
            puddle.addColorStop(.82,litBlood(event.dark ? "#1b1029" : "#752338",event.depth))
            puddle.addColorStop(1,litBlood(event.dark ? "#001b1029" : "#00752338",event.depth))
            ctx.fillStyle=puddle
            ctx.globalAlpha*=Math.min(.82,age*2.3)
            ctx.beginPath()
            for (let s=0;s<=16;s++) {
                const angle=s*Math.PI/8
                const edge=pool*(.77+.23*Math.sin(s*6.82+event.id))
                ctx.lineTo(point.x+Math.cos(angle)*edge,floor+Math.sin(angle)*edge*.31)
            }
            ctx.closePath()
            ctx.fill()
        }
        if (event.boss && event.fatal)
            rupture(ctx,point,scale,progress,age,event.type,event.depth,visibility)
        ctx.globalAlpha = 1
    }

    function rupture(ctx,point,scale,progress,age,type,depth,visibility) {
        const profile = deaths[type]
        if (!profile)
            return
        for (let i=0; i<profile.waves; ++i) {
            const ring = Math.max(0,(age-i*.072)*2)
            if (!ring)
                continue
            const radius = scale*(.23+ring*profile.reach)
            ctx.globalAlpha=visibility*Math.max(0,.36-ring*.32)
            ctx.strokeStyle=litBlood(i%2 ? profile.flesh : profile.spark,depth)
            ctx.lineWidth = Math.max(1,scale*(.072-ring*.03))
            ctx.beginPath()
            ctx.ellipse(point.x-radius,point.y-radius*.64,radius*2,radius*1.28)
            ctx.stroke()
        }
        ctx.globalAlpha=visibility*Math.min(.83,1.14-progress)
        for (let i=0; i<profile.organs; ++i) {
            const angle = i*2.399+profile.twist*age*3.2
            const strength = .37+i%5*.15
            const stretch = age*(.86+age)*scale*strength
            const x = point.x+Math.cos(angle)*stretch*profile.reach*1.6
            const y = point.y+Math.sin(angle)*stretch*profile.lift-scale*age*.94+scale*age*age*2.5
            const body = scale*(.065+i%4*.038)*(1.19-age*.47)
            ctx.save()
            ctx.translate(x,y)
            ctx.rotate(angle+age*7)
            ctx.strokeStyle = type === "reapfast" ? "#11091c" : "#4d132d"
            ctx.lineWidth = 1+body*.28
            ctx.beginPath()
            ctx.moveTo(-body*.5,0)
            ctx.bezierCurveTo(-body*1.6,body*.62,-body*2.1,-body*1.2,-body*3.8,body*.55)
            ctx.stroke()
            ctx.fillStyle=litBlood(profile.flesh,depth)
            ctx.beginPath()
            ctx.moveTo(-body,body*.31)
            ctx.bezierCurveTo(-body*1.66,-body,body*.61,-body*1.33,body*.92,-body*.24)
            ctx.bezierCurveTo(body*1.62,body*.87,-body*.62,body*1.38,-body,body*.31)
            ctx.fill()
            ctx.strokeStyle=litBlood(i%4 ? profile.spark : "#9c5d52",depth)
            ctx.globalAlpha*=.51
            ctx.lineWidth=Math.max(1,body*.12)
            ctx.beginPath();ctx.moveTo(-body*.39,-body*.30);ctx.quadraticCurveTo(.0,-body*.70,body*.36,-body*.35);ctx.stroke()
            ctx.globalAlpha=visibility*Math.min(.83,1.14-progress)
            ctx.restore()
        }
    }

    function aura(ctx, enemy, danger) {
        const where = project(Rules.lanePosition(enemy), Rules.elevation(enemy), enemy.depth)
        const x = where.pos.x
        const y = where.pos.y
        const radius = Math.max(19, Math.min(width*.50, where.scale * Rules.enemySize(enemy) * (danger === "Overlord" ? 209 : 157)))
        const glow = ctx.createRadialGradient(x,y,radius*.41,x,y,radius)
        glow.addColorStop(0, "transparent")
        glow.addColorStop(.68, danger === "Overlord" ? "#36f85d1b" : "#4b1c092b")
        glow.addColorStop(1, "transparent")
        ctx.globalAlpha = Rules.materialization(enemy)*(ultra ? .54 : 1)
        ctx.fillStyle = glow
        ctx.fillRect(x-radius,y-radius,radius*2,radius*2)
        if (danger === "Overlord") {
            for (let i = 0; i < 7; i += 1) {
                const age = ((motion ? enemy.age*.98 : .13) + i*.147)%1
                const emberX = x + (i/6-.5)*radius*1.38 + Math.sin(age*8+i)*radius*.09
                const emberY = y + radius*(.48-age*1.12)
                ctx.globalAlpha = (1-age)*.52*Rules.materialization(enemy)
                ctx.fillStyle = i%3 ? "#f6774c" : "#ffca81"
                ctx.fillRect(emberX,emberY,2+radius*.014,3+radius*.024)
            }
        }
        ctx.globalAlpha = 1
    }

    function paintSplit(ctx,event) {
        const where = project(event.lane,event.elevation,event.depth)
        const scale = where.scale * event.size
        for (const side of [-1,1]) {
            const pose = CutArt.motion(event,side,motion)
            const angle = pose.cut*Math.PI/180
            ctx.save()
            ctx.translate(where.pos.x+Math.cos(angle)*pose.offset*scale,
                where.pos.y-(pose.rise+Math.sin(angle)*pose.offset)*scale)
            ctx.rotate(-(pose.cut+pose.roll)*Math.PI/180)
            ctx.scale(side*scale*Math.max(.29,Math.abs(Math.cos(pose.yaw*Math.PI/180))),scale)
            ctx.globalAlpha = pose.alpha
            ctx.fillStyle = Qt.darker(Rules.enemyTypes[event.type].skin,1.13)
            ctx.beginPath()
            ctx.moveTo(0,-90)
            ctx.quadraticCurveTo(61,-82,59,-35)
            ctx.lineTo(123,-63)
            ctx.lineTo(87,9)
            ctx.quadraticCurveTo(53,14,48,39)
            ctx.quadraticCurveTo(36,73,0,77)
            ctx.fill()
            ctx.fillStyle = pose.seam
            ctx.beginPath()
            ctx.ellipse(-5,-88,10,164)
            ctx.fill()
            ctx.restore()
        }
    }

    function paintWell(ctx,hole) {
        const where = project(hole.lane,hole.elevation,hole.depth)
        const radius = Math.max(12,where.scale * 110 * (.78+.73*hole.pulse))
        const age = motion ? hole.duration-hole.life : .18
        ctx.save()
        ctx.translate(where.pos.x,where.pos.y)
        ctx.globalAlpha = Math.min(1,hole.life/.38)
        if (projected) {
            ctx.fillStyle = "#10091f"
            ctx.beginPath()
            ctx.arc(0,0,radius*.64,0,2*Math.PI)
            ctx.fill()
        }
        for (let i = 0; i < (projected ? 5 : 2); ++i) {
            ctx.strokeStyle = i%2 ? "#fcc5ff" : "#b375fc"
            ctx.lineWidth = 1 + radius*.024
            ctx.save()
            ctx.rotate(age*.86+i*.31)
            ctx.scale(1,.41+i*.06)
            ctx.beginPath()
            ctx.arc(0,0,radius*(1+i*.13),age*5+i,age*5+i+1.85)
            ctx.stroke()
            ctx.restore()
        }
        ctx.restore()
    }

    function specialArrival(ctx,enemy) {
        const pool = ["liquid","rise","sink"].includes(enemy.warpKind)
        const divine = enemy.warpKind === "divine"
        if (!pool && !divine && enemy.warpKind !== "alienArrival")
            return
        const where = project(Rules.lanePosition(enemy),pool ? -127 : Rules.elevation(enemy),enemy.depth)
        const progress = 1-Rules.warpFraction(enemy)
        const x = where.pos.x
        const y = where.pos.y
        const radius = Math.max(39,where.scale*Rules.enemySize(enemy)*(pool ? 108 : 83))
        ctx.save()
        ctx.globalAlpha = Math.min(1,Math.sin(progress*Math.PI)*1.34)
        if (pool) {
            const liquid = ctx.createRadialGradient(x,y,radius*.25,x,y,radius)
            liquid.addColorStop(0,"#f103020b")
            liquid.addColorStop(.65,"#e80b0312")
            liquid.addColorStop(1,"#004e2564")
            for (let i=0;i<4;++i) {
                const swell = radius*(.52+progress*.37+i*.14)
                ctx.fillStyle = liquid
                ctx.strokeStyle = i%2 ? "#8c47255f" : "#ab1f122f"
                ctx.lineWidth = 1+i*.68
                ctx.beginPath()
                ctx.ellipse(x-swell,y-swell*.30,swell*2,swell*.60)
                ctx.fill()
                ctx.stroke()
            }
            for (let i=0;i<21;++i) {
                const d = (progress*1.35+i*.173)%1
                const px = x+Math.sin(i*19.8+d*5)*radius*d
                const py = y-Math.sin(Math.PI*d)*radius*(.38+i%4*.24)
                ctx.fillStyle = i%5 ? "#1d0c2a" : "#704281"
                ctx.beginPath()
                ctx.ellipse(px,py,3+i%4*2,4+i%3*3)
                ctx.fill()
            }
        } else {
            const color = divine ? "#fff1ad" : "#7feaff"
            const width = radius*(.37+Math.sin(progress*6.3)*.13)
            const shaft = ctx.createLinearGradient(x-width,0,x+width,0)
            shaft.addColorStop(0,"transparent")
            shaft.addColorStop(.43,color)
            shaft.addColorStop(.57,color)
            shaft.addColorStop(1,"transparent")
            ctx.fillStyle = shaft
            ctx.fillRect(x-width,divine ? 0 : y-radius*1.37,width*2,divine ? Math.max(5,y+radius*.45) : radius*2.55)
            ctx.strokeStyle = color
            ctx.lineWidth = 2
            for (let i=0;i<3;++i) {
                const r = radius*(.61+i*.22)
                ctx.beginPath()
                ctx.ellipse(x-r,y-r*.22+(divine ? radius*.59 : (i-1)*radius*.45),r*2,r*.44)
                ctx.stroke()
            }
        }
        ctx.restore()
    }

    onPaint: {
        const ctx = beginPaint()
        ctx.clearRect(0,0,width,height)
        if (!world || !active)
            return
        for (const enemy of run.enemies) {
            if (enemy.front !== frontId || enemy.waitingBoss)
                continue
            const danger = Encounters.tier(enemy.type)
            if (danger === "Nightmare" || danger === "Overlord")
                aura(ctx,enemy,danger)
            const spec = seals[enemy.type]
            if (enemy.warp > 0) {
                if (spec && ["spawn","drop","rise","liquid","divine"].includes(enemy.warpKind))
                    reveal(ctx,enemy,spec)
                specialArrival(ctx,enemy)
            }
            if (enemy.type === "fetaSpotter" && Rules.warningProgress(enemy) > 0) {
                const lens = project(Rules.lanePosition(enemy), Rules.elevation(enemy)+26, enemy.depth)
                ctx.strokeStyle = "#91ff5557"
                ctx.lineWidth = 1.6
                ctx.beginPath()
                ctx.moveTo(lens.pos.x,lens.pos.y)
                ctx.lineTo(width*.50,height*.48)
                ctx.stroke()
            }
            if (enemy.type === "faeel" && !enemy.warp)
                eelCharge(ctx,enemy)
        }
        for (const hole of run.holes) {
            if (hole.front === frontId)
                paintWell(ctx,hole)
        }
        if (projected) {
            for (const body of run.splits) {
                if (body.front === frontId)
                    paintSplit(ctx,body)
            }
        }
        for (const event of run.gore) {
            if (event.front === frontId && (!event.crystal || projected))
                spill(ctx,event)
        }
    }
}

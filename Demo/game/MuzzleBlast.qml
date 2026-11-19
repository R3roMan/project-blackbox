import QtQuick

Canvas {
    id: blast
    required property var weapon
    required property color tint
    required property point tip
    required property point aim
    required property real life
    property bool motion: true
    property int sequence: 0
    property bool ultra: false
    readonly property string family:weapon.staff ? "rune" : weapon.effect
    readonly property real strength: Math.max(0,Math.min(1,life/Math.max(.06,weapon.afterglow)))
    readonly property real widthScale:family==="rocket" || family==="spread" ? 1.27
        : family==="beam" || family==="laser" || family==="rune" ? 1.07 : .85
    width: Math.max(98,Math.min(235,parent.height*.24))*widthScale
    height: width
    x: tip.x-width*.5
    y: tip.y-height*.5
    visible: strength>.015 && !weapon.melee && !weapon.throwing
    opacity: motion ? 1 : .68
    transformOrigin: Item.Center
    rotation: Math.atan2(aim.y-tip.y,aim.x-tip.x)*180/Math.PI
    onStrengthChanged: if (visible) requestPaint()
    onSequenceChanged: if (visible) requestPaint()
    onTintChanged: if (visible) requestPaint()
    onFamilyChanged: if (visible) requestPaint()
    onUltraChanged: if (visible) requestPaint()
    onVisibleChanged: if (visible) requestPaint()
    onWidthChanged: if (visible) requestPaint()

    function detailedBlast(c, size, energy, radiant, shell, pigment) {
        const age = 1 - energy
        const hot = Math.pow(energy, 1.9)
        const length = size * (shell ? .87 : radiant ? .69 : .57)
        if (motion && family !== "laser") {
            for (let i = 0; i < 4; ++i) {
                const expansion = size * (.18 + age * .26 + i * .025)
                const x = size * (age * (.21 + i * .052) + i * .07)
                const y = -size * age * (.10 + i * .049) + Math.sin(i * 7 + sequence) * size * .075
                const smoke = c.createRadialGradient(x,y,0,x,y,expansion)
                smoke.addColorStop(0,radiant ? Qt.rgba(tint.r,tint.g,tint.b,.45) : "#b4876870")
                smoke.addColorStop(.48,radiant ? "#63535692" : "#86645766")
                smoke.addColorStop(1,"transparent")
                c.globalAlpha = Math.sin(Math.PI * age) * .65
                c.fillStyle = smoke
                c.fillRect(x-expansion,y-expansion,expansion*2,expansion*2)
            }
        }

        const radius = size * (.50 + hot * .28)
        const glow = c.createRadialGradient(length*.19,0,0,length*.19,0,radius)
        glow.addColorStop(0,"#fffeee")
        glow.addColorStop(.23,pigment)
        glow.addColorStop(.57,radiant ? Qt.rgba(tint.r,tint.g,tint.b,.48) : "#abdf612e")
        glow.addColorStop(1,"transparent")
        c.globalAlpha = hot * .88
        c.fillStyle = glow
        c.fillRect(-radius, -radius, radius * 2 + length*.19, radius * 2)

        const rays = shell ? 9 : 7
        for (let i = 0; i < rays; ++i) {
            const angle = (i === 0 ? 0 : (i*2.399+sequence*.37))
            const sweep = length * (i === 0 ? 1 : .31 + (i % 4) * .13) * (.79 + hot*.21)
            const spread = size * (i % 3 === 0 ? .126 : .076)
            c.save()
            c.rotate(angle)
            c.beginPath()
            c.moveTo(-size*.08,0)
            c.quadraticCurveTo(sweep*.29,-spread*1.7,sweep,0)
            c.quadraticCurveTo(sweep*.25,spread*1.25,-size*.08,0)
            const ray = c.createLinearGradient(0,0,sweep,0)
            ray.addColorStop(0,"#fffdea")
            ray.addColorStop(.46,pigment)
            ray.addColorStop(1,radiant ? Qt.rgba(tint.r,tint.g,tint.b,.46) : "#73fd5624")
            c.fillStyle = ray
            c.fill()
            c.restore()
        }
        c.fillStyle = "#ffffed"
        c.beginPath()
        c.ellipse(-size*.13,-size*.075,length*.78,size*.15)
        c.fill()

        if (radiant) {
            c.globalAlpha = energy * .69
            c.strokeStyle = pigment
            c.lineWidth = Math.max(1,size*.018)
            c.beginPath()
            c.ellipse(-size*.11,-size*(.32+age*.21),size*(.15+age*.22),size*(.64+age*.42))
            c.stroke()
        }
        if (family === "rune") {
            c.globalAlpha = energy * .86
            c.strokeStyle = "#fff1d7"
            c.beginPath()
            for (let i = 0; i < 6; ++i) {
                const angle = i * Math.PI / 3 + age * 2.2
                const x = Math.cos(angle) * radius * .62
                const y = Math.sin(angle) * radius * .62
                if (i) c.lineTo(x,y)
                else c.moveTo(x,y)
            }
            c.closePath()
            c.stroke()
        }
        if (motion && family !== "laser") {
            for (let i = 0; i < (shell ? 19 : 12); ++i) {
                const angle = (i*.618%1-.50) * (shell ? 2.94 : 1.87)
                    + Math.sin(i*6+sequence)*.16
                const travel = size * (.22 + age*(.45+i%4*.074) + i%3*.094)
                const x = Math.cos(angle) * travel
                const y = Math.sin(angle) * travel + age * age * size * .13
                c.globalAlpha = energy * (.44+i%4*.17)
                c.strokeStyle = i % 3 ? pigment : "#fffbe3"
                c.lineWidth = Math.max(1,size*(.009+i%3*.005))
                c.beginPath()
                c.moveTo(x - Math.cos(angle) * size*(.044+energy*.10), y - Math.sin(angle)*size*.12)
                c.lineTo(x,y)
                c.stroke()
            }
        }
    }

    onPaint: {
        const c=getContext("2d")
        c.reset()
        c.clearRect(0,0,width,height)
        if (!visible) return
        const side=width*.5, energy=strength
        const age=1-energy
        const radiant=family==="beam" || family==="laser" || family==="rune"
        const shell=family==="rocket" || family==="spread"
        const pulse=family==="pulse" || family==="burst"
        const pigment=radiant || pulse ? tint : shell ? "#ffa94f" : "#ffd08a"
        c.translate(side,side)
        if (ultra) {
            detailedBlast(c,side,energy,radiant || family==="pulse",shell,
                radiant || family==="pulse" ? pigment : weapon.element==="frost" ? "#baeaff" : shell ? "#ffad53" : "#ffcb76")
            return
        }
        const radius=side*(shell ? .69 : radiant ? .57 : .46)*(1+age*.23)
        const glow=c.createRadialGradient(0,0,1,0,0,radius)
        glow.addColorStop(0,"#fffcde")
        glow.addColorStop(.21,pigment)
        glow.addColorStop(.54,Qt.rgba(tint.r,tint.g,tint.b,.54))
        glow.addColorStop(1,"transparent")
        c.globalAlpha=energy*.86
        c.fillStyle=glow
        c.fillRect(-radius,-radius,radius*2,radius*2)
        if (radiant || pulse) {
            c.strokeStyle=pigment
            c.lineWidth=side*(radiant ? .036 : .024)
            c.beginPath()
            c.ellipse(-side*(.08+age*.12),-side*(.30+age*.14),side*(.12+age*.32),side*(.60+age*.28))
            c.stroke()
        }
        if (family==="rune") {
            c.strokeStyle="#fff0ca"
            c.lineWidth=Math.max(1,side*.018)
            c.beginPath()
            for (let i=0;i<7;i++) {
                const angle=i*Math.PI/3+age*2.1
                const x=Math.cos(angle)*radius*.56, y=Math.sin(angle)*radius*.56
                if (!i) c.moveTo(x,y)
                else c.lineTo(x,y)
            }
            c.stroke()
        } else {
            c.fillStyle="#fff9ce"
            c.beginPath()
            const flare=side*(shell ? .83 : radiant ? .67 : .51)
            const jitter=(sequence%3-1)*.11
            for (let i=0;i<14;i++) {
                const angle=i*Math.PI/7+jitter
                const distance=i%2 ? flare*.22 : flare*(i===0 ? 1.13 : i===7 ? .62 : .54)
                const x=distance*Math.cos(angle), y=distance*Math.sin(angle)
                if (!i) c.moveTo(x,y)
                else c.lineTo(x,y)
            }
            c.closePath()
            c.fill()
        }
        if (motion && family!=="laser") {
            c.strokeStyle=pigment
            c.lineWidth=Math.max(1,side*.022)
            c.globalAlpha=energy*.68
            for (let i=0;i<(shell ? 10 : 6);i++) {
                const angle=(i*.284-1.32)+(sequence%4-1.5)*.10
                const spread=side*(.37+age*.46+(i%3)*.069)
                const x=Math.cos(angle),y=Math.sin(angle)
                c.beginPath();c.moveTo(x*spread*.75,y*spread*.75)
                c.lineTo(x*spread,y*spread);c.stroke()
            }
        }
    }
}

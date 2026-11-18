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
    onVisibleChanged: if (visible) requestPaint()
    onWidthChanged: if (visible) requestPaint()

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

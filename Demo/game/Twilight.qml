import QtQuick

EffectCanvas {
    id:sky
    objectName:"twilightSky"
    required property string condition
    required property real clock
    required property bool motion
    textureLimit:1050
    frameRate:12
    readonly property bool dawn:condition==="sunrise"
    readonly property real drift:motion ? Math.sin(clock*.022) : 0
    onDriftChanged:requestPaint()
    onConditionChanged:requestPaint()
    onPaint: {
        const c=beginPaint()
        c.clearRect(0,0,width,height)
        const horizon=height*(.43+drift*.045)
        const band=c.createLinearGradient(0,0,0,height)
        band.addColorStop(0,dawn ? "rgba(76,39,103,.32)" : "rgba(77,22,63,.41)")
        band.addColorStop(.22,dawn ? "rgba(201,90,97,.29)" : "rgba(187,51,63,.44)")
        band.addColorStop(.48,dawn ? "rgba(255,167,91,.50)" : "rgba(244,104,55,.50)")
        band.addColorStop(.76,"rgba(105,37,41,.22)")
        band.addColorStop(1,"rgba(39,16,29,.12)")
        c.fillStyle=band
        c.fillRect(0,0,width,height)
        const x=width*((dawn ? .22 : .76)+drift*.12)
        const bloom=c.createRadialGradient(x,horizon,0,x,horizon,Math.max(1,width*.48))
        bloom.addColorStop(0,dawn ? "rgba(255,218,146,.63)" : "rgba(255,173,85,.57)")
        bloom.addColorStop(.38,dawn ? "rgba(255,157,103,.26)" : "rgba(236,82,53,.26)")
        bloom.addColorStop(1,"transparent")
        c.fillStyle=bloom;c.fillRect(0,0,width,height)

        // Far enough from the player to read as weather, with a smooth
        // pulse instead of a bright screen flash.
        if (!motion) return
        for (let strike=0;strike<2;strike++) {
            const time=clock+strike*8.9
            const age=time%18
            const glow=Math.max(0,Math.sin(Math.min(1,age/3.6)*Math.PI))*.32
            if (glow<.01) continue
            const start=width*((.15+strike*.53+Math.floor(time/18)*.19)%1)
            c.strokeStyle=Qt.rgba(1,.77,.57,glow)
            c.lineWidth=Math.max(1,width*.00135)
            c.beginPath()
            c.moveTo(start,horizon-height*.26)
            for (let i=1;i<=7;i++)
                c.lineTo(start+i*width*.0125+Math.sin(i*7.43+strike)*width*.023,horizon+height*(-.26+i*.029+age*.008))
            c.stroke()
            c.lineWidth*=.6
            c.beginPath()
            const split=start+4*width*.0125+Math.sin(4*7.43+strike)*width*.023
            c.moveTo(split,horizon+height*(-.144+age*.008))
            c.lineTo(split-width*.041,horizon-height*.098)
            c.lineTo(split-width*.050,horizon-height*.041)
            c.stroke()
        }
    }
}

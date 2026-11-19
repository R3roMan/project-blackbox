import QtQuick

// This material follows the lab photograph's separate upright and floor planes.
EffectCanvas {
    objectName:"bloodyLab"
    textureLimit:1500
    onPaint: {
        const c=beginPaint()
        c.clearRect(0,0,width,height)
        c.scale(width/768,height/432)
        let seed=83711
        function noise() {seed=(Math.imul(1664525,seed)+1013904223)>>>0;return seed/4294967296}
        function blot(x,y,r,scaleY,tone) {
            c.fillStyle=tone
            c.beginPath()
            for(let j=0;j<19;j++) {
                const a=j*Math.PI*2/19,dist=r*(.6+noise()*.53)
                const px=x+Math.cos(a)*dist,py=y+Math.sin(a)*dist*scaleY
                if (j===0)c.moveTo(px,py)
                else c.lineTo(px,py)
            }
            c.closePath();c.fill()
        }
        // A film of blood clings to the tank and pools in the grooves of the
        // steel floor. Concentrate the colour without hiding the fittings.
        const tank=c.createLinearGradient(0,119,0,259)
        tank.addColorStop(0,"#68570b16");tank.addColorStop(.67,"#9d6a0715");tank.addColorStop(1,"#ce53060c")
        c.fillStyle=tank
        c.beginPath();c.moveTo(309,121);c.quadraticCurveTo(385,109,467,121)
        c.lineTo(467,255);c.quadraticCurveTo(391,266,310,257);c.closePath();c.fill()
        for(const pool of [[145,371,87,.12],[357,323,57,.15],[472,398,137,.15],[680,343,79,.12],[34,426,67,.2]]) {
            blot(pool[0],pool[1],pool[2],pool[3],"#db47060e")
            blot(pool[0]-4,pool[1],pool[2]*.77,pool[3]*.93,"#dd5c0910")
        }
        const stains=["#db440a10","#db670d13","#d3520912","#bc860f17","#d23a060e"]
        for (const spill of [[90,202,48],[196,232,31],[269,112,35],[323,159,32],[393,225,44],
                            [454,141,31],[577,155,49],[664,205,55],[731,91,42],[500,54,29],[184,36,32],[42,134,30],
                            [154,371,80],[354,319,62],[480,392,114],[666,345,69],[41,422,58]]) {
            const floor=spill[1]>300, squash=floor ? .28 : .94
            for (let i=0;i<98;i++) {
                const a=noise()*Math.PI*2, dist=Math.pow(noise(),1.7)*spill[2]*1.42
                const x=spill[0]+Math.cos(a)*dist,y=spill[1]+Math.sin(a)*dist*squash
                const r=(1+Math.pow(noise(),3)*22)*(1-dist/(spill[2]*2))
                blot(x,y,r,squash,stains[i%stains.length])
                if (!floor && i%8===0) {
                    const len=9+noise()*45
                    c.strokeStyle="#bd620b12";c.lineWidth=.8+noise()*2.4
                    c.beginPath();c.moveTo(x,y);c.bezierCurveTo(x-1,y+len*.3,x+1,y+len*.72,x,y+len);c.stroke()
                }
                if (floor && i%5===0) {
                    c.fillStyle="#adac3530";c.fillRect(x-3,y-1,4+r,.7)
                }
            }
        }
    }
}

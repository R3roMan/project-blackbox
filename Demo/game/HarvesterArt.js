.pragma library

function draw(ctx,time,open) {
    ctx.fillStyle = "#eee2d4"
    ctx.beginPath()
    ctx.moveTo(.22,.12)
    ctx.bezierCurveTo(.50,-.04,.85,.08,.80,.43)
    ctx.lineTo(.73,.73)
    ctx.lineTo(.62,.91)
    ctx.lineTo(.37,.89)
    ctx.lineTo(.26,.71)
    ctx.closePath()
    ctx.fill()
    const features = [[.35,.35,.13,.12+open*.07],[.65,.35,.13,.12+open*.07],[.50,.69,.18,.11+open*.16]]
    for (let feature=0; feature<features.length; ++feature) {
        const [x,y,wide,tall] = features[feature]
        ctx.fillStyle = "#0a050e"
        ctx.beginPath()
        ctx.ellipse(x-wide,y-tall,wide*2,tall*2)
        ctx.fill()
        for (let pass=0; pass<6; ++pass) {
            ctx.beginPath()
            for (let point=0; point<=32; ++point) {
                const angle = point/32*Math.PI*2+time*(feature===2 ? -1.4 : 1.8)+pass*.5
                const r = 1+Math.sin(angle*7+pass*1.7+time*18)*.10
                const px = x+Math.cos(angle)*(wide+.006*pass)*r
                const py = y+Math.sin(angle)*(tall+.004*pass)*r
                if (!point)
                    ctx.moveTo(px,py)
                else
                    ctx.lineTo(px,py)
            }
            ctx.strokeStyle = pass%3 ? "#a7170a21" : "#f42b1737"
            ctx.lineWidth = .003+pass%2*.001
            ctx.stroke()
        }
        if (feature < 2) {
            ctx.fillStyle = "#fbf7ef"
            ctx.beginPath()
            ctx.ellipse(x-.039,y-.037-open*.02,.078,.074+open*.04)
            ctx.fill()
            ctx.strokeStyle="#e2040308"
            ctx.lineWidth=.008
            ctx.beginPath()
            ctx.moveTo(x-.06,y+Math.sin(time*11+feature)*.02)
            ctx.lineTo(x+.06,y-Math.sin(time*11+feature)*.02)
            ctx.stroke()
        }
    }
    ctx.fillStyle="#26152b"
    ctx.beginPath()
    ctx.moveTo(.49,.40)
    ctx.lineTo(.455,.51)
    ctx.lineTo(.54,.505)
    ctx.closePath()
    ctx.fill()
    for (let i=0; i<13; ++i) {
        ctx.beginPath()
        const x=.23+(i*.193)% .53
        const y=.14+(i*.117)%.64
        ctx.moveTo(x,y)
        ctx.lineTo(x+.025,y+.021)
        ctx.lineTo(x+.016,y+.047)
        ctx.strokeStyle="#886f5968"
        ctx.lineWidth=.0026
        ctx.stroke()
    }
}

.pragma library
.import "HarvesterArt.js" as Ink

function shape(ctx, points, color, width, line) {
    ctx.beginPath()
    ctx.moveTo(points[0],points[1])
    for (let i=2; i<points.length; i+=2)
        ctx.lineTo(points[i],points[i+1])
    ctx.closePath()
    ctx.fillStyle = color
    ctx.fill()
    if (line) {
        ctx.strokeStyle = line
        ctx.lineWidth = width
        ctx.stroke()
    }
}

function oval(ctx,x,y,w,h,color) {
    ctx.fillStyle = color
    ctx.beginPath()
    ctx.ellipse(x,y,w,h)
    ctx.fill()
}

function draw(ctx, foe, skin, accent, time, tell, lamp, mirror) {
    const kind = foe.type
    if (kind === "harvester") {
        shape(ctx,[.17,.77,.20,.45,.30,.16,.55,.10,.75,.28,.81,.74,.73,.92,.66,.82,.58,.97,.47,.86,.36,.96,.25,.83,.18,.94],
            skin,.013,"#b58fba")
        oval(ctx,.24,.36,.53,.50,"#24152e")
        ctx.save()
        ctx.translate(.25,.10)
        ctx.scale(.5,.56)
        Ink.draw(ctx,time,foe.soulChannel ? 1 : tell)
        ctx.restore()
        return
    }
    if (kind === "crufixicatus") {
        ctx.save()
        ctx.translate(1,1)
        ctx.rotate(Math.PI)
        shape(ctx,[.46,.32,.54,.32,.57,.66,.53,.74,.48,.69,.44,.49],skin,.007,"#77717c")
        for (const side of [-1,1]) {
            shape(ctx,[.5+side*.06,.36,.5+side*.15,.46,.5+side*.19,.73,.5+side*.22,.79,.5+side*.22,.68,.5+side*.14,.34],skin)
            shape(ctx,[.5+side*.04,.65,.5+side*.095,.79,.5+side*.10,.99,.5+side*.16,1,.5+side*.11,.75],skin)
            oval(ctx,.5+side*.057-.04,.257,.08,.076,"#08050c")
            for (let i=0; i<8; ++i) {
                const drift = (time*.84+i*.173)%1
                oval(ctx,.5+side*.057+Math.sin(drift*4+i)*.01,.287-drift*.26,.006,.018,"#bb2749")
            }
        }
        oval(ctx,.391,.17,.218,.20,skin)
        oval(ctx,.420,.27,.052,.048,"#08050c")
        oval(ctx,.530,.27,.052,.048,"#08050c")
        oval(ctx,.446,.333,.108,.022+tell*.071,"#160a1a")
        ctx.strokeStyle="#17101b"
        ctx.lineWidth=.003
        for (let i=0; i<13; ++i) {
            const x=.40+(.5+.5*Math.sin((foe.id||1)*3.17+i*9.31))*.19
            const y=.18+(i*.033)%.14
            ctx.beginPath()
            ctx.moveTo(x,y)
            ctx.lineTo(x+.011,y+.01)
            ctx.lineTo(x+.003,y+.023)
            ctx.stroke()
        }
        ctx.restore()
        return
    }
    if (kind === "skorochiyus") {
        for (let i=0; i<28; ++i) {
            const drift = (i*.213+time*(.74+i%4*.07))%1
            oval(ctx,.5+Math.cos(i*2.4+drift*3)*(.27+drift*.21),.84-drift*.85,.013+i%3*.014,.035+i%4*.013,
                i%3 ? "#eaf66d38" : "#ffffce74")
        }
        shape(ctx,[.2,.63,.22,.30,.30,.17,.44,.1,.65,.13,.8,.27,.83,.63,.67,.71,.64,.86,.36,.86,.34,.68],
            "#d8af85",.02,"#9c694e")
        oval(ctx,.27,.31,.18,.15,"#2b1517")
        oval(ctx,.55,.31,.18,.15,"#2b1517")
        oval(ctx,.31,.332,.10,.093,"#ff932e")
        oval(ctx,.58,.332,.10,.093,"#ffdb55")
        oval(ctx,.35,.58,.29,.14+tell*.14,"#3e1919")
        oval(ctx,.40,.60,.21,.11+tell*.10,"#e15d27")
        oval(ctx,.469,.47,.027,.060,"#24131a")
        oval(ctx,.510,.47,.027,.060,"#24131a")
        return
    }
    if (kind === "fearme") {
        shape(ctx,[.19,.87,.27,.44,.34,.22,.48,.13,.62,.23,.65,.45,.78,.86,.60,.75,.48,.94,.33,.79],
            "#211327",.016,"#72416e")
        oval(ctx,.37,.23,.20,.22,"#130b1e")
        oval(ctx,.403,.327,.035,.027,accent)
        oval(ctx,.493,.327,.035,.027,accent)
        const lean = tell*.26
        shape(ctx,[.66,.95,.646,.90,.71-lean,.18,.75-lean,.20],"#84617e")
        shape(ctx,[.70-lean,.21,.58-lean,.09,.40-lean,.05,.57-lean,.06,.86-lean,.15,.98-lean,.29,.84-lean,.23],
            "#ae659f",.014,"#efabd9")
        return
    }
    if (kind === "nightosphere") {
        for (let i=0; i<23; ++i) {
            const angle = i*2.4+time*.71
            const radius = .14+(1-(time*.72+i*.156)%1)*.31
            ctx.fillStyle = i%5 ? "#130920" : accent
            ctx.fillRect(.5+Math.cos(angle)*radius,.52+Math.sin(angle)*radius,.014+i%3*.006,.025)
        }
        shape(ctx,[.50,.15,.74,.31,.82,.53,.65,.79,.41,.85,.19,.59,.25,.37],skin,.017,accent)
        shape(ctx,[.5,.15,.57,.44,.82,.53,.65,.79,.57,.63,.41,.85,.19,.59,.57,.44],"#1b0f2c",.009,"#bf72e4")
        return
    }
    if (["tenmani","shadow","hallucination","endme"].includes(kind)) {
        const tall = kind === "endme"
        const ink = kind === "shadow" || kind === "hallucination"
        const width = tall ? .28 : ink ? .35+((foe.illusionForm || 0)%3)*.10 : .53
        for (let i=0; i<(tall ? 2 : 9); ++i) {
            const x = tall ? .37+.28*i : .28+.055*i
            const side = i%2 ? -1 : 1
            ctx.beginPath()
            ctx.moveTo(x,.43)
            ctx.bezierCurveTo(x+side*(.14+tell*.12),.63,x-side*.12,.83,
                x+side*.16+Math.sin(time*5+i)*.035,.91+Math.cos(time*4+i)*.038)
            ctx.lineWidth = tall ? .055 : .032+i%3*.015
            ctx.strokeStyle = i%3 ? skin : "#190f22"
            ctx.stroke()
        }
        oval(ctx,.5-width*.5,.13,width,tall ? .69 : .50,skin)
        if (kind === "shadow") {
            const flick = tell*.19
            shape(ctx,[.63,.51,.70,.79,.92,.35-flick,.85,.38-flick],"#312049",.013,accent)
        }
        if (ink) {
            for (let i=0; i<17; ++i) {
                const a = (i*.173+time*.83)%1
                oval(ctx,.48+Math.sin(i*3.1+a*7)*(.18+a*.31),.28+a*.64,.023,.030,i%5 ? "#1c1224" : accent)
            }
        }
        for (let i=0; i<(tall ? (foe.eyeCount ?? 8) : 2); ++i) {
            const x = i%2 ? .53 : .395
            oval(ctx,x,.277+Math.floor(i*.5)*.10,.074,.045,accent)
        }
        return
    }
    if (kind === "archfellanus") {
        shape(ctx,[.28,.30,.67,.24,.87,.96,.66,.82,.54,.94,.46,.84,.25,.96,.15,.72],"#170b20",.008,"#6c3756")
        shape(ctx,[.43,.33,.57,.33,.68,.82,.51,.91,.34,.82],skin,.017,"#ccbba4")
        oval(ctx,.37,.17,.26,.24,"#685064")
        oval(ctx,.37,.105,.26,.049,"#2c1e27")
        oval(ctx,.42,.258,.058,.034,accent)
        oval(ctx,.53,.253,.058,.034,"#fc776d")
        if (mirror) {
            ctx.beginPath()
            ctx.ellipse(.13,.08,.74,.86)
            ctx.fillStyle = "#48ffee88"
            ctx.fill()
            ctx.lineWidth = .025
            ctx.strokeStyle = "#ffe9a5"
            ctx.stroke()
        }
        return
    }

    const big = kind === "reapfast"
    const eel = kind === "faeel"
    const doll = kind === "lalaBubu"
    if (big || eel || kind === "crawler") {
        const count = big ? 14 : eel ? 11 : 6
        for (let i=count-1; i>=0; --i) {
            const taper = 1-i/count
            const x = .35+i/count*.47+Math.sin(time*4-i*.70)*(.02+.007*i)
            const y = .40+i/count*.41
            oval(ctx,x,y,.31*taper+.07,.26*taper+.07,skin)
            oval(ctx,x+.055,y+.048,.13*taper,.023,big ? "#63d4eb" : eel ? "#f0cf67" : "#677b92")
            if (eel && i%2) {
                ctx.strokeStyle = "#a36ce1"
                ctx.lineWidth = .013
                ctx.beginPath()
                ctx.moveTo(x-.03,y-.03)
                ctx.lineTo(x+.075,y+.02)
                ctx.lineTo(x+.08,y+.071)
                ctx.lineTo(x+.16,y+.082)
                ctx.stroke()
            }
        }
    }
    if (kind === "lantis") {
        for (let i=0; i<13; ++i) {
            const a = i*2*Math.PI/13
            const x = .48+Math.cos(a)*.31
            const y = .55+Math.sin(a)*.34
            shape(ctx,[x,y,x+.045,y+.055,x+.115*Math.cos(a),y+.13*Math.sin(a)],skin,.007,"#6e512f")
        }
    }
    if (doll) {
        oval(ctx,.14,.18,.18,.24,"#744059")
        oval(ctx,.68,.18,.17,.24,"#744059")
        shape(ctx,[.32,.54,.66,.54,.77,.84,.59,.89,.54,.98,.49,.88,.35,.98,.32,.87,.23,.81],"#7d284e",.011,"#b48997")
    }
    if (big)
        ctx.globalAlpha *= .77
    oval(ctx,big ? .11 : .19,.205,big ? .70 : .61,big ? .57 : .59,skin)
    const dark = .18+tell*(big ? .42 : .28)
    oval(ctx,big ? .13 : .28,.437,big ? .64 : .43,dark,"#0d0811")
    const teeth = big ? 13 : 9
    for (let i=0; i<teeth; ++i) {
        const x = (big ? .17 : .31)+i*(big ? .047 : .043)
        const edge = Math.sin(i/(teeth-1)*Math.PI)*.026
        shape(ctx,[x,.47-edge,x+.026,.47-edge,x+.014,.54-edge+(i%3)*.021],"#f0d4b5",0,"")
        shape(ctx,[x,.425+dark+edge,x+.023,.425+dark+edge,x+.01,.37+dark+edge],"#d8beab",0,"")
    }
    for (const x of [.32,.59]) {
        oval(ctx,x-.04,.303,.16,.112,"#120a17")
        oval(ctx,x+(doll ? .023 : 0),.323,doll ? .041 : big ? .1 : .074,big ? .08 : .055,accent)
    }
    if (kind === "lantis") {
        ctx.beginPath()
        ctx.moveTo(.49,.28)
        ctx.quadraticCurveTo(.50,.053,.68,.16)
        ctx.lineWidth = .025
        ctx.strokeStyle = "#74553a"
        ctx.stroke()
        if (lamp) {
            const light = ctx.createRadialGradient(.68,.16,.02,.68,.16,.22)
            light.addColorStop(0,"#ecffd76f")
            light.addColorStop(1,"#00ffbb65")
            ctx.fillStyle = light
            ctx.fillRect(.46,0,.44,.40)
        }
        oval(ctx,.637,.124,.084,.076,lamp ? "#fff1aa" : "#625335")
    }
}

import QtQuick

Canvas {
    id: badge
    required property var entry
    required property color tint
    property bool onPaper:false
    readonly property bool activeAbility:entry?.category === "Active"
    readonly property bool passiveAbility:entry?.category === "Passive"
    readonly property color pigment:({
        blood:"#a8294c", frost:"#237da7", bolt:"#6a3ac3", flame:"#b24224",
        shield:"#25738a", cross:"#3d8067", cache:"#987016", target:"#b43259",
        stride:"#177658", burst:"#a3432f", eclipse:"#563478", vial:"#4e771e",
        weave:"#5a627e"
    })[motif]
    readonly property string motif: {
        const title = ((entry?.id || "")+" "+(entry?.title || "")).toLowerCase()
        if (/blood|sanguin|hematic|vampir|heart|siphon/.test(title)) return "blood"
        if (entry?.element === "freeze" || /ice|frost|winter|cryo|rime|frozen/.test(title)) return "frost"
        if (entry?.element === "electric" || /electric|shock|storm|thunder|static|arc/.test(title)) return "bolt"
        if (entry?.element === "burn" || /fire|ember|sunfall|kiln|burn|flam|inferno/.test(title)) return "flame"
        if (/shield|ward|guard|bastion|plating|plate|armour|parry|aegis/.test(title)) return "shield"
        if (/heal|medic|pulse|mercy|second wind|recovery|repair/.test(title)) return "cross"
        if (/gold|coin|mint|spare|stash|magazine|reserve/.test(title)) return "cache"
        if (/aim|mark|critical|scope|snip|focus|sight|eye/.test(title)) return "target"
        if (/wind|drift|dash|quick|swift|reload|speed|runner|surge/.test(title)) return "stride"
        if (/bomb|mine|grenade|blast|burst|deton|frag|mortar/.test(title)) return "burst"
        if (/void|night|dark|shadow|rift|moon|blind/.test(title)) return "eclipse"
        if (/poison|spore|ve[nm]om|mire|toxin|corros/.test(title)) return "vial"
        return activeAbility ? "stride" : "weave"
    }
    onWidthChanged:requestPaint()
    onHeightChanged:requestPaint()
    onEntryChanged:requestPaint()
    onTintChanged:requestPaint()
    onOnPaperChanged:requestPaint()

    function polygon(ctx, vertices, filled) {
        ctx.beginPath()
        ctx.moveTo(vertices[0],vertices[1])
        for (let i=2; i<vertices.length; i+=2) ctx.lineTo(vertices[i],vertices[i+1])
        ctx.closePath()
        if (filled) ctx.fill()
        else ctx.stroke()
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        const unit = Math.min(width,height)/88
        if (unit <= 0) return
        const border = onPaper ? Qt.darker(tint,1.48) : tint
        ctx.translate(width/2,height/2)
        ctx.scale(unit,unit)
        ctx.strokeStyle=border
        ctx.lineWidth=2.3
        ctx.fillStyle=onPaper ? Qt.rgba(pigment.r,pigment.g,pigment.b,.16) : activeAbility ? "#452834" : "#243342"
        ctx.lineJoin="round"
        ctx.lineCap="round"
        if (activeAbility) {
            const outline=[0,-41,37,-6,28,24,0,40,-28,24,-37,-6]
            polygon(ctx,outline,true)
            polygon(ctx,outline,false)
            ctx.fillStyle=border
            polygon(ctx,[-5,-39,0,-44,5,-39,0,-33],true)
        } else {
            ctx.beginPath()
            ctx.moveTo(-32,-35)
            ctx.lineTo(32,-35)
            ctx.lineTo(30,11)
            ctx.quadraticCurveTo(26,29,0,40)
            ctx.quadraticCurveTo(-26,29,-30,11)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
            ctx.beginPath()
            ctx.moveTo(-25,-28);ctx.lineTo(25,-28)
            ctx.moveTo(-17,24);ctx.lineTo(0,32);ctx.lineTo(17,24)
            ctx.stroke()
        }
        ctx.fillStyle=onPaper ? pigment : "#ffe8d3"
        ctx.strokeStyle=ctx.fillStyle
        ctx.lineWidth=2.6
        switch (motif) {
        case "blood":
            ctx.beginPath()
            ctx.moveTo(0,-21)
            ctx.bezierCurveTo(-2,-12,-16,1,-14,11)
            ctx.bezierCurveTo(-12,26,12,26,14,11)
            ctx.bezierCurveTo(16,1,2,-12,0,-21)
            ctx.fill()
            break
        case "frost":
            for (let i=0;i<6;i++) {
                ctx.save(); ctx.rotate(i*Math.PI/3)
                ctx.beginPath()
                ctx.moveTo(0,0);ctx.lineTo(0,-21)
                ctx.moveTo(-5,-15);ctx.lineTo(0,-10);ctx.lineTo(5,-15)
                ctx.stroke();ctx.restore()
            }
            break
        case "bolt":
            polygon(ctx,[6,-24,-14,4,-2,4,-8,24,15,-6,3,-6],true)
            break
        case "flame":
            ctx.beginPath()
            ctx.moveTo(-4,-22)
            ctx.bezierCurveTo(-4,-8,-18,-5,-16,8)
            ctx.bezierCurveTo(-12,27,12,27,15,8)
            ctx.quadraticCurveTo(16,-3,7,-12)
            ctx.quadraticCurveTo(8,-2,3,0)
            ctx.quadraticCurveTo(5,-12,-4,-22)
            ctx.fill()
            break
        case "shield":
            polygon(ctx,[-17,-17,17,-17,15,7,9,16,0,21,-9,16,-15,7],false)
            polygon(ctx,[0,-9,7,2,0,12,-7,2],true)
            break
        case "cross":
            polygon(ctx,[-5,-17,5,-17,5,-5,17,-5,17,5,5,5,5,17,-5,17,-5,5,-17,5,-17,-5,-5,-5],true)
            break
        case "cache":
            for (let i=0;i<3;i++) {
                ctx.strokeRect(-13,-14+11*i,26,8)
                ctx.fillRect(4,-12+11*i,6,4)
            }
            break
        case "target":
            ctx.beginPath();ctx.arc(0,0,12,0,Math.PI*2);ctx.stroke()
            for (let i=0;i<4;i++) {
                ctx.save();ctx.rotate(i*Math.PI/2);ctx.beginPath();ctx.moveTo(0,-21);ctx.lineTo(0,-8);ctx.stroke();ctx.restore()
            }
            ctx.fillRect(-2,-2,4,4)
            break
        case "stride":
            polygon(ctx,[-19,-12,-8,-12,6,0,-8,12,-19,12,-5,0],true)
            polygon(ctx,[0,-12,10,-12,24,0,10,12,0,12,14,0],true)
            break
        case "burst":
            polygon(ctx,[0,-22,5,-8,18,-13,12,0,20,8,7,10,4,23,-4,12,-18,16,-12,5,-23,-3,-8,-7],true)
            break
        case "eclipse":
            ctx.beginPath();ctx.arc(-2,0,18,-1.43,1.43,true);ctx.quadraticCurveTo(-11,0,0,-18);ctx.fill()
            polygon(ctx,[11,-9,14,-2,21,0,14,2,11,9,8,2,1,0,8,-2],true)
            break
        case "vial":
            polygon(ctx,[-6,-18,6,-18,6,-7,14,7,14,16,-14,16,-14,7,-6,-7],false)
            ctx.fillRect(-10,6,20,7)
            ctx.fillRect(2,-5,4,4)
            break
        default:
            polygon(ctx,[0,-18,17,0,0,18,-17,0],false)
            polygon(ctx,[0,-10,10,0,0,10,-10,0],true)
        }
    }
}

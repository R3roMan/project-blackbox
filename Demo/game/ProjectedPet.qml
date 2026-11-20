import QtQuick

Canvas {
    id: pet
    objectName: "projectedPet"
    required property var helper
    required property real flap
    property string idlePose:"flight"
    property string expression:"neutral"
    onIdlePoseChanged:requestPaint()
    onExpressionChanged:requestPaint()
    property bool resting: false
    property color glowTint:"transparent"
    property bool motion: true
    property real strike: 0
    property real fold: resting ? 1 : 0
    Behavior on fold { enabled: pet.motion; NumberAnimation { duration: 270; easing.type: Easing.InOutSine } }
    readonly property bool angry: strike > .04 || expression==="upset"
    readonly property bool machine: ["wasp", "kite", "ray", "beetle"].includes(helper.form)
    readonly property bool membrane: ["bat", "ray", "drake", "fox"].includes(helper.form)
    onFlapChanged: requestPaint()
    onFoldChanged: requestPaint()
    onStrikeChanged: requestPaint()
    onHelperChanged: requestPaint()
    onGlowTintChanged:requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        if (glowTint.a>0) {
            ctx.shadowColor=glowTint
            ctx.shadowBlur=Math.min(10,width*.09)
        }
        ctx.scale(width, height)
        ctx.fillStyle = Qt.lighter(pet.helper.skin, 1.35)
        ctx.strokeStyle = pet.helper.accent
        ctx.lineWidth = .032
        if (pet.helper.form==="surfPrimate") {
            function oval(x,y,w,h,color) {ctx.fillStyle=color;ctx.beginPath();ctx.ellipse(x,y,w,h);ctx.fill()}
            if (idlePose==="vine") {
                ctx.strokeStyle="#5e9056";ctx.beginPath();ctx.moveTo(.60,0);ctx.quadraticCurveTo(.83,.15,.58,.34);ctx.stroke()
            } else oval(.13,.78,.75,.10,"#f4bd42")
            oval(.29,.41,.43,.34,"#694899");oval(.33,.51,.35,.20,"#243e55")
            oval(.27,.29,.15,.15,"#9571ab");oval(.61,.28,.15,.15,"#9571ab");oval(.32,.20,.36,.34,"#7453a0")
            oval(.38,.37,.25,.13,"#b693c3");oval(.405,.30,.060,.074,"#fff1bb");oval(.535,.30,.06,.074,"#fff1bb")
            oval(.433,.322,.032,.044,"#292133");oval(.542,.318,.034,.043,"#292133")
            oval(pet.expression==="happy" ? .426 : .455,.431,pet.expression==="happy" ? .15 : .09,idlePose==="laugh" ? .06 : .026,"#302033")
            oval(.31,.18,.38,.074,"#203c55")
            if (pet.expression==="upset") {
                path(ctx,[.392,.282,.469,.310,.465,.325,.390,.298],"#292133")
                path(ctx,[.535,.309,.601,.280,.602,.298,.534,.326],"#292133")
            }
            if (idlePose==="thumbs") {oval(.65,.45,.15,.10,"#9571ab");oval(.753,.367,.045,.15,"#b693c3")}
            if (idlePose==="banana" || idlePose==="throw") oval(.32,.441,.16,.046,"#f6d258")
            if (idlePose==="globe") {oval(.71,.14,.18,.20,"#3789ba");oval(.761,.17,.048,.117,"#9acb70")}
            return
        }
        if (["crow","owl","finch","chicken","falcon"].includes(pet.helper.form)) {
            drawBird(ctx)
            return
        }
        if (pet.helper.form==="jacko") {
            drawJacko(ctx)
            return
        }
        if (pet.helper.crawl) {
            ctx.lineWidth = .026
            for (let i = 0; i < 8; i += 1) {
                const side = i < 4 ? -1 : 1
                const step = Math.sin(i * 1.9 + pet.flap * 2.5) * .07 * (1 - pet.fold)
                const offset = i % 4 * .105
                ctx.beginPath()
                ctx.moveTo(.5 + side * .12, .53)
                ctx.lineTo(.5 + side * (.22 + offset * .37), .50 + offset + step)
                ctx.lineTo(.5 + side * (.44 - offset * .38 - pet.fold * .065), .87 - offset * .4 + step)
                ctx.stroke()
            }
            for (let i = 0; i < 12; i += 1) {
                ctx.fillStyle = i % 3 ? pet.helper.skin : Qt.lighter(pet.helper.skin, 1.4)
                ctx.beginPath()
                ctx.ellipse(.38 + Math.cos(i * 2.4) * .13, .37 + Math.sin(i * 2.4) * .16, .23, .27)
                ctx.fill()
                ctx.stroke()
            }
            ctx.fillStyle = pet.angry ? "#ffe893" : pet.helper.accent
            ctx.fillRect(.44, .55, .035, .045 - pet.fold * .028)
            ctx.fillRect(.52, .55, .035, .045 - pet.fold * .028)
            if (pet.angry)
                brows(ctx)
            return
        }
        if (pet.helper.form === "minishade") {
            for (let i=0;i<8;++i) {
                const x=.27+i*.067
                ctx.beginPath()
                ctx.moveTo(x,.39)
                ctx.bezierCurveTo(x+pet.flap*.051,.61,x+Math.sin(i)*.09,.72,x+.075,.92-Math.sin(i*1.8)*.06)
                ctx.lineWidth=.067
                ctx.strokeStyle=i%3 ? "#2c1c40" : "#120a20"
                ctx.stroke()
            }
            ctx.fillStyle=pet.helper.skin
            ctx.beginPath()
            ctx.ellipse(.25,.17,.50,.52)
            ctx.fill()
            ctx.fillStyle=pet.angry ? "#ff82df" : pet.helper.accent
            ctx.fillRect(.37,.40,.098,.05 - pet.fold * .034)
            ctx.fillRect(.54,.40,.098,.05 - pet.fold * .034)
            return
        }
        const wingspan=1-pet.fold*.50
        for (const side of [-1, 1]) {
            ctx.beginPath()
            ctx.moveTo(.5, .51)
            ctx.lineTo(.5 + side * .46 * wingspan, .22 - pet.flap * .19 + pet.fold * .39)
            ctx.lineTo(.5 + side * .34 * wingspan, (pet.membrane ? .64 : .49) + pet.fold * .18)
            ctx.lineTo(.5 + side * .23 * wingspan, (pet.membrane ? .49 : .61) + pet.fold * .12)
            ctx.lineTo(.5 + side * .18 * wingspan, .65)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
            ctx.strokeStyle = Qt.darker(pet.helper.skin, 1.34)
            ctx.lineWidth = .013
            for (let i = 0; i < 3; i += 1) {
                ctx.beginPath()
                ctx.moveTo(.50 + side * (.21+i*.065) * wingspan,.46 + pet.fold*.13)
                ctx.lineTo(.50 + side * (.28+i*.038) * wingspan,.48+pet.flap*.07 + pet.fold*.20)
                ctx.stroke()
            }
        }
        if (pet.helper.form === "fairy" || pet.helper.form === "chibi") {
            const fairy = pet.helper.form === "fairy"
            ctx.fillStyle = fairy ? "#49775f" : "#c75d91"
            for (const side of [-1,1]) {
                ctx.beginPath()
                ctx.ellipse(.40+side*.14,.25,.22,fairy ? .27 : .42)
                ctx.fill()
            }
            ctx.fillStyle = pet.helper.skin
            ctx.beginPath()
            ctx.moveTo(.50,.47)
            ctx.lineTo(fairy ? .68 : .70,.90)
            ctx.lineTo(fairy ? .32 : .30,.90)
            ctx.closePath()
            ctx.fill()
            ctx.fillStyle = "#eabcab"
            ctx.beginPath()
            ctx.ellipse(.323,.271,.356,.354)
            ctx.fill()
            ctx.fillStyle = fairy ? "#506850" : "#e37db2"
            ctx.beginPath()
            ctx.ellipse(.320,.202,.362,.189)
            ctx.fill()
            ctx.fillStyle = pet.angry ? "#fff290" : pet.helper.accent
            ctx.fillRect(.385,.418,.082,.070 - pet.fold * .048)
            ctx.fillRect(.534,.418,.082,.070 - pet.fold * .048)
            if (pet.angry)
                brows(ctx)
            ctx.fillStyle = "#7e4054"
            ctx.fillRect(.476,.558,.048,.022)
            return
        }
        ctx.fillStyle = pet.helper.skin
        ctx.beginPath()
        ctx.ellipse(.32, .29, .36, .47)
        ctx.fill()
        ctx.stroke()
        if (pet.helper.form==="wasp" || pet.helper.form==="beetle" || pet.helper.id==="firefly") {
            for (let i=0;i<4;i++)
                oval(ctx,.38+i*.018,.61+i*.050,.24-i*.036,.16, i%2 ? "#23202e" : pet.helper.accent)
        }
        if (pet.helper.form==="moth" || pet.helper.form==="ray") {
            for (const side of [-1,1]) {
                oval(ctx,.415+side*.26,.39,.17,.15,Qt.darker(pet.helper.skin,2.2))
                oval(ctx,.465+side*.26,.416,.071,.087,pet.helper.accent)
            }
        }
        if (["fox","bat","drake","kite"].includes(pet.helper.form)) {
            for (const side of [-1,1]) {
                const spread=pet.helper.form==="kite" ? .31 : .13
                path(ctx,[.5+side*(spread+.10),.40,.5+side*(spread+.046),.13+(pet.helper.id==="wyvern" ? -.05 : 0),
                    .5+side*(spread-.063),.42],pet.helper.form==="fox" ? "#deb999" : pet.helper.accent)
            }
        }
        ctx.fillStyle = pet.angry ? "#fff09a" : pet.helper.accent
        ctx.fillRect(.39, .42, .065, .075 - pet.fold * .052)
        ctx.fillRect(.55, .42, .065, .075 - pet.fold * .052)
        if (pet.angry)
            brows(ctx)
        ctx.fillStyle = pet.helper.form === "chicken" ? "#e5a462" : pet.machine ? "#b8d9ec" : "#171823"
        ctx.beginPath()
        ctx.moveTo(.45, .56)
        ctx.lineTo(.55, .56)
        ctx.lineTo(.5, .68)
        ctx.closePath()
        ctx.fill()
    }

    function oval(ctx,x,y,w,h,color) {
        ctx.fillStyle=color
        ctx.beginPath();ctx.ellipse(x,y,w,h);ctx.fill()
    }

    function path(ctx,points,color) {
        ctx.beginPath();ctx.moveTo(points[0],points[1])
        for (let index=2; index<points.length; index+=2) ctx.lineTo(points[index],points[index+1])
        ctx.closePath();ctx.fillStyle=color;ctx.fill()
    }

    function drawJacko(ctx) {
        const embers = pet.angry ? "#c0ff73" : "#82e95d"
        for (let i=0;i<6;i++) {
            const x=.27+i*.094
            const bend=(i%2 ? -.1 : .1)*(pet.flap*.4+.6)
            ctx.fillStyle=i%3===0 ? embers : "#398d46"
            ctx.globalAlpha=(1-pet.fold)*(.46+i%3*.17)
            ctx.beginPath()
            ctx.moveTo(x,.54)
            ctx.bezierCurveTo(x-.14,.34,x+bend,.25,x+bend,.06+i%3*.05)
            ctx.bezierCurveTo(x+.12,.27,x+.10,.46,x,.54)
            ctx.fill()
        }
        ctx.globalAlpha=1
        ctx.fillStyle="#4c4927"
        ctx.fillRect(.47,.25,.10,.20)
        for (const i of [0,4,1,3,2]) {
            const offset=Math.abs(i-2)
            ctx.fillStyle=i%2 ? "#db7532" : "#a34c22"
            ctx.strokeStyle="#623323"
            ctx.lineWidth=.018
            ctx.beginPath()
            ctx.ellipse(.16+i*.083,.35+offset*.04,.35,.6-offset*.078)
            ctx.fill()
            ctx.stroke()
        }
        ctx.fillStyle=embers
        for (const side of [-1,1]) {
            ctx.beginPath()
            ctx.moveTo(.5+side*.06,.59)
            ctx.lineTo(.5+side*.24,.52+pet.fold*.072)
            ctx.lineTo(.5+side*.146,.68-pet.fold*.068)
            ctx.fill()
        }
        ctx.globalAlpha=1-.72*pet.fold
        ctx.beginPath()
        ctx.moveTo(.28,.68)
        ctx.lineTo(.39,.73)
        ctx.lineTo(.42,.69)
        ctx.lineTo(.52,.77)
        ctx.lineTo(.58,.71)
        ctx.lineTo(.63,.74)
        ctx.lineTo(.75,.63)
        ctx.quadraticCurveTo(.54,.97,.28,.68)
        ctx.fill()
        ctx.globalAlpha=1
    }

    function drawBird(ctx) {
        const wendy=helper.id==="chicken", owl=helper.id==="owl", finch=helper.id==="finch", raven=helper.id==="archive"
        const falcon=helper.form==="falcon"
        const tan=falcon ? "#b4cdd4" : wendy ? "#f0d7af" : owl ? "#c6a062" : finch ? "#c3d5a1" : raven ? "#baccc4" : "#6d5668"
        const bill=wendy || finch || falcon ? "#e4af5b" : owl ? "#b98755" : "#191a25"
        for (const side of [-1,1]) {
            const tip=owl ? .46 : finch ? .34 : wendy ? .33 : .46
            for (let i=0;i<6;i++) {
                const reach=tip-i*(finch ? .041 : .049)
                const y=(owl ? .23 : .16)+i*.064-flap*.18+fold*(.38-i*.028)
                const span=1-fold*.47
                path(ctx,[.5+side*.12,.43,.5+side*reach*span,y,.5+side*(reach-.051)*span,y+.17,.5+side*.16,.68],
                    i%3===1 ? Qt.lighter(helper.skin,1.36) : helper.skin)
            }
            path(ctx,[.5+side*.076,.70,.5+side*.087,.84-fold*.10,.5+side*.156,.88-fold*.13,.5+side*.055,.90-fold*.12,.5+side*.049,.72],bill)
        }
        oval(ctx, wendy ? .265 : .32, .33,wendy ? .47 : .36,wendy ? .43 : .38,helper.skin)
        oval(ctx,.355,.426,.29,.26,tan)
        oval(ctx,owl ? .31 : .364,owl ? .24 : .25,owl ? .38 : .272,owl ? .35 : .33,Qt.lighter(helper.skin,1.28))
        if (wendy) {
            for (let i=0;i<4;i++)
                oval(ctx,.427+i*.048,.17-i%2*.052,.079,.132,"#de494d")
            oval(ctx,.466,.54,.064,.12,"#d84248")
        } else if (owl || raven) {
            for (const side of [-1,1])
                path(ctx,[.5+side*.11,.37,.5+side*.156,.19,.5+side*.068,.30],helper.skin)
        }
        if (falcon) {
            for (let index=0;index<3;index++) {
                const x=.43+.067*index
                path(ctx,[x-.027,.28,x-.017,.12+Math.abs(index-1)*.057,x+.022,.259],"#96dce5")
            }
            if (strike>0 || idlePose==="frost")
                for (let index=0;index<6;index++) {
                    const x=.15+.137*index, y=.19+((index*7)%13)*.049+flap*.10
                    path(ctx,[x,y-.068,x+.03,y,x,y+.054,x-.024,y],"#bef5ff")
                }
        }
        for (const side of [-1,1]) {
            const x=.50+side*(owl ? .095 : .067)
            if (owl || finch) oval(ctx,x-.071,.318,.142,.156,tan)
            oval(ctx,x-.041,.372+fold*.033,.082,.091-fold*.067,"#151420")
            if (fold < .62) oval(ctx,x-.027,.388,.054,(angry ? .031 : expression==="happy" ? .074 : .057)*(1-fold),angry ? "#ff544a" : helper.accent)
        }
        if (angry) brows(ctx)
        path(ctx,[.451,.475,.55,.475,.52+(raven ? .043 : 0),finch ? .534 : .588,.49,.562],bill)
    }

    function brows(ctx) {
        const y = pet.helper.crawl ? .53 : .40
        ctx.strokeStyle = "#251d2b"
        ctx.lineWidth = .030
        ctx.beginPath()
        ctx.moveTo(.375,y)
        ctx.lineTo(.468,y+.052)
        ctx.moveTo(.532,y+.052)
        ctx.lineTo(.629,y)
        ctx.stroke()
    }
}

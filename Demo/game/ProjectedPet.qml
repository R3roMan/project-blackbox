import QtQuick

Canvas {
    id: pet
    objectName: "projectedPet"
    required property var helper
    required property real flap
    property bool resting: false
    property real strike: 0
    readonly property bool angry: strike > .04
    readonly property bool machine: ["wasp", "kite", "ray", "beetle"].includes(helper.form)
    readonly property bool membrane: ["bat", "ray", "drake", "fox"].includes(helper.form)
    onFlapChanged: requestPaint()
    onStrikeChanged: requestPaint()
    onHelperChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        ctx.scale(width, height)
        ctx.fillStyle = Qt.lighter(pet.helper.skin, 1.35)
        ctx.strokeStyle = pet.helper.accent
        ctx.lineWidth = .032
        if (pet.helper.crawl) {
            ctx.lineWidth = .026
            for (let i = 0; i < 8; i += 1) {
                const side = i < 4 ? -1 : 1
                const step = Math.sin(i * 1.9 + pet.flap * 2.5) * .07
                const offset = i % 4 * .105
                ctx.beginPath()
                ctx.moveTo(.5 + side * .12, .53)
                ctx.lineTo(.5 + side * (.22 + offset * .37), .50 + offset + step)
                ctx.lineTo(.5 + side * (.44 - offset * .38), .87 - offset * .4 + step)
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
            ctx.fillRect(.44, .55, .035, .045)
            ctx.fillRect(.52, .55, .035, .045)
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
            ctx.fillRect(.37,.40,.098,.05)
            ctx.fillRect(.54,.40,.098,.05)
            return
        }
        for (const side of [-1, 1]) {
            ctx.beginPath()
            ctx.moveTo(.5, .51)
            ctx.lineTo(.5 + side * .46, .22 - pet.flap * .19)
            ctx.lineTo(.5 + side * .34, pet.membrane ? .64 : .49)
            ctx.lineTo(.5 + side * .23, pet.membrane ? .49 : .61)
            ctx.lineTo(.5 + side * .18, .65)
            ctx.closePath()
            ctx.fill()
            ctx.stroke()
            ctx.strokeStyle = Qt.darker(pet.helper.skin, 1.34)
            ctx.lineWidth = .013
            for (let i = 0; i < 3; i += 1) {
                ctx.beginPath()
                ctx.moveTo(.50 + side * (.21+i*.065),.46)
                ctx.lineTo(.50 + side * (.28+i*.038),.48+pet.flap*.07)
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
            ctx.fillRect(.385,.418,.082,.070)
            ctx.fillRect(.534,.418,.082,.070)
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
        if (pet.helper.form === "chicken") {
            ctx.fillStyle = "#c93842"
            for (let i = 0; i < 3; i += 1) {
                ctx.beginPath()
                ctx.ellipse(.406+i*.060,.20-i%2*.060,.081,.15)
                ctx.fill()
            }
            ctx.beginPath()
            ctx.ellipse(.482,.62,.068,.105)
            ctx.fill()
        }
        ctx.fillStyle = pet.angry ? "#fff09a" : pet.helper.accent
        ctx.fillRect(.39, .42, .065, .075)
        ctx.fillRect(.55, .42, .065, .075)
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

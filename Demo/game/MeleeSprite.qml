import QtQuick

Canvas {
    id: blade
    required property string weaponId
    required property color accent
    property real action: 0
    property real spin: 0
    property bool primed: false
    property real clock: 0

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onWeaponIdChanged: requestPaint()
    onActionChanged: requestPaint()
    onSpinChanged: if (weaponId === "chainsaw") requestPaint()
    onPrimedChanged: requestPaint()
    onAccentChanged: requestPaint()
    onClockChanged: requestPaint()

    function polygon(ctx, points, fill) {
        ctx.beginPath()
        ctx.moveTo(points[0], points[1])
        for (let i = 2; i < points.length; i += 2)
            ctx.lineTo(points[i], points[i+1])
        ctx.closePath()
        ctx.fillStyle = fill
        ctx.fill()
        ctx.strokeStyle = "#221929"
        ctx.lineWidth = 3
        ctx.stroke()
    }

    function steel(ctx, top, bottom) {
        const gradient = ctx.createLinearGradient(0,top,0,bottom)
        gradient.addColorStop(0,"#edf4ff")
        gradient.addColorStop(.29,"#a9acb9")
        gradient.addColorStop(.48,"#605d71")
        gradient.addColorStop(.62,"#bbbcc8")
        gradient.addColorStop(1,"#333246")
        return gradient
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        ctx.scale(width / 336, height / 170)
        const hot = primed ? Qt.lighter(accent, 1.45) : accent
        if (weaponId === "breakerGlaive") {
            polygon(ctx,[35,37,312,123,322,137,307,151,31,61],"#33303a")
            polygon(ctx,[10,17,91,35,155,76,118,88,67,57,15,46],steel(ctx,17,88))
            polygon(ctx,[10,17,91,35,147,70,94,47,11,25],hot)
            return
        }
        if (weaponId === "fearScythe") {
            polygon(ctx,[76,41,307,122,322,140,304,154,67,63],"#262035")
            polygon(ctx,[132,59,95,31,15,16,41,31,56,64,79,94,73,57,103,63,126,79],steel(ctx,16,106))
            polygon(ctx,[15,16,57,20,105,37,135,59,119,64,82,42,39,26],hot)
            return
        }
        if (weaponId === "helltrident") {
            polygon(ctx,[38,53,305,119,299,142,32,72],"#33313a")
            polygon(ctx,[35,34,56,38,71,76,55,95,25,104,40,83,28,73,10,76,31,53,18,34,24,12],steel(ctx,14,104))
            for (let i = 0; i < 8; i += 1) {
                const age = (clock * 1.65 + i*.173)%1
                const x = 11+i*6 + Math.sin(age*6+i)*4
                const y = 61-age*49+(i%3)*10
                ctx.fillStyle = i%3 ? "#ef693d" : "#ffd186"
                ctx.globalAlpha = (1-age)*.79
                ctx.beginPath()
                ctx.moveTo(x-8,y+9)
                ctx.quadraticCurveTo(x-11,y-4,x+2,y-23)
                ctx.quadraticCurveTo(x+5,y-7,x+6,y+9)
                ctx.closePath()
                ctx.fill()
            }
            return
        }
        if (weaponId === "chainsaw") {
            polygon(ctx, [10,49,188,39,239,52,240,95,159,109,23,98,9,82], steel(ctx,46,107))
            polygon(ctx, [198,36,264,31,294,52,303,114,283,144,234,126,210,91], "#a94032")
            polygon(ctx, [250,31,268,10,308,12,326,61,304,67,293,39], "#282635")
            for (let i = 0; i < 12; i += 1) {
                const x = 15+i*16+(spin % 36) / 3
                polygon(ctx, [x-5,47,x+2,35,x+8,48], "#f3ede6")
                polygon(ctx, [206-x,100,210-x,112,216-x,100], "#e4d9d4")
            }
            ctx.fillStyle = hot
            ctx.fillRect(215, 51, 46, 12)
            return
        }
        if (weaponId === "gravhammer" || weaponId === "reaperscythe") {
            polygon(ctx, [75,34,311,128,304,149,68,53], "#43404b")
            if (weaponId === "gravhammer") {
                polygon(ctx, [16,17,141,19,155,37,149,69,130,87,20,81,7,63], steel(ctx,17,87))
                polygon(ctx, [13,23,39,30,38,75,18,79,8,61], "#d3d1db")
                polygon(ctx, [45,34,130,39,123,48,51,46], hot)
            } else {
                polygon(ctx, [82,31,153,16,210,22,249,48,269,87,230,65,192,51,145,51,87,56], steel(ctx,16,87))
                polygon(ctx, [153,45,200,42,229,53,249,72,269,87,235,61,192,52,148,54], hot)
            }
            polygon(ctx, [218,95,311,128,304,149,215,114], "#55303a")
            return
        }
        if (weaponId === "tomahawk" || weaponId === "nailclub") {
            const axe = weaponId === "tomahawk"
            polygon(ctx, [43,64,133,60,299,108,311,126,295,146,121,96,44,91], axe ? "#775139" : "#986039")
            if (axe) {
                polygon(ctx, [65,20,112,45,137,70,135,104,87,110,45,134,17,108,12,66], steel(ctx,20,134))
                polygon(ctx, [64,20,36,64,39,100,45,134,18,112,12,66], hot)
                polygon(ctx, [118,52,151,60,158,86,134,99,116,88], "#665266")
            } else {
                polygon(ctx, [34,45,147,50,189,70,184,108,127,111,25,85], "#986039")
                for (let i=0; i<8; i+=1)
                    polygon(ctx, [32+i*16,66,36+i*16,i%2 ? 94 : 26,43+i*16,68], "#c8c2bc")
            }
            for (let i=0; i<5; i+=1)
                polygon(ctx, [235+i*12,95+i*3,245+i*12,98+i*3,237+i*12,122+i*3,229+i*12,119+i*3], "#56313d")
            return
        }

        const handles = weaponId === "duoknives" ? [-1, 1] : [0]
        for (const side of handles) {
            ctx.save()
            ctx.translate(side ? 234-side*30 : 266, 91 + side*29)
            ctx.rotate(side * (.075 + Math.sin(action * Math.PI*2) * .05))
            polygon(ctx, [-12,-17,49,-15,62,3,49,21,-12,12], "#653349")
            polygon(ctx, [-28,-26,-10,-30,4,20,-13,31,-28,15], "#b9947d")
            if (weaponId === "darksaber") {
                const length = 221-9*action
                polygon(ctx, [-21,-18,-length,-20,-length-21,-8,-length-10,7,-21,11], hot)
                polygon(ctx, [-25,-11,-length+6,-13,-length-8,-7,-length+3,0,-25,5], "#1b0e2c")
            } else if (weaponId === "mechasword") {
                const extend = action * 14
                polygon(ctx, [-24,-22,-182-extend,-31,-237-extend,-17,-190-extend,14,-36,22], steel(ctx,-31,21))
                polygon(ctx, [-31,-20,-184-extend,-27,-229-extend,-17,-54,2,-28,8], hot)
                polygon(ctx, [-58,-24,-85,-27,-82,14,-53,11], "#b5ccd5")
            } else {
                const reach = side ? 148 : 252
                polygon(ctx, [-22,-14,-reach+34,-21,-reach,-30,-reach+10,-9,-reach+43,8,-25,14], steel(ctx,-30,14))
                polygon(ctx, [-25,8,-reach+39,4,-reach,-30,-reach+14,-9,-reach+41,8,-25,14], primed ? hot : "#dce9ff")
                ctx.strokeStyle = "#8a777f"
                ctx.lineWidth = 1.15
                for (let i=0; i<5; i+=1) {
                    ctx.beginPath()
                    ctx.moveTo(-42-i*18, -14)
                    ctx.lineTo(-50-i*18, -4)
                    ctx.stroke()
                }
            }
            ctx.restore()
        }
    }
}

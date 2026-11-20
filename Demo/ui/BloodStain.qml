import QtQuick

Canvas {
    id: stain
    property int seed: 7
    property bool spatter: false
    property bool mirrorX: false
    property bool mirrorY: false

    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onSeedChanged: requestPaint()
    onSpatterChanged: requestPaint()
    onVisibleChanged: if (visible) requestPaint()

    function grain(index) {
        const sample = Math.sin(index * 12.9898 + seed * 31.7) * 43758.5453
        return sample - Math.floor(sample)
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)
        if (!visible || !width || !height)
            return
        ctx.translate(mirrorX ? width : 0, mirrorY ? height : 0)
        ctx.scale((mirrorX ? -1 : 1) * width / 220, (mirrorY ? -1 : 1) * height / 110)

        const wash = ctx.createLinearGradient(0, 0, 96, 65)
        wash.addColorStop(0, "#881207")
        wash.addColorStop(.47, "#9f142e")
        wash.addColorStop(1, "#14551022")
        ctx.fillStyle = wash
        ctx.beginPath()
        ctx.moveTo(0, 0)
        ctx.lineTo(172, 0)
        ctx.bezierCurveTo(151, 6, 132, 3, 122, 11)
        ctx.bezierCurveTo(116, 18, 99, 10, 89, 18)
        ctx.bezierCurveTo(74, 32, 67, 14, 56, 29)
        ctx.bezierCurveTo(46, 40, 44, 28, 32, 36)
        ctx.bezierCurveTo(18, 53, 15, 33, 0, 54)
        ctx.closePath()
        ctx.fill()

        if (spatter) {
            for (let i=0;i<13;++i) {
                const angle=.05+grain(i+136)*1.53
                const reach=36+grain(i+149)*112
                const mass=grain(i+160)
                const x=4+Math.cos(angle)*reach
                const y=2+Math.sin(angle)*reach*.66
                ctx.fillStyle=i%3===0 ? "#a4bc2340" : "#aa861028"
                ctx.beginPath()
                ctx.moveTo(2+i*1.75,3)
                ctx.quadraticCurveTo(x*.38+10,y*.52-7,x,y)
                ctx.quadraticCurveTo(x*.57,y*.43+10+mass*6,1,5+i)
                ctx.closePath()
                ctx.fill()
            }
        }

        for (let i = 0; i < 6; ++i) {
            const x = 7 + i * 17 + grain(i) * 9
            const start = 9 - i * .7
            const end = start + 15 + grain(i + 32) * (i < 3 ? 78 : 42)
            const size = 1.5 + grain(i + 8) * (i < 3 ? 4.9 : 2.9)
            const drift = (grain(i + 11) - .5) * 13
            const clot = ctx.createLinearGradient(x, start, x + drift, end + 5)
            clot.addColorStop(0, "#aa701125")
            clot.addColorStop(.66, "#bb8e142b")
            clot.addColorStop(1, "#49b51730")
            ctx.fillStyle = clot
            ctx.beginPath()
            ctx.moveTo(x - size, start)
            ctx.bezierCurveTo(x - size * .7, end * .55, x + drift - size * .86, end - 9, x + drift - size * .6, end)
            ctx.bezierCurveTo(x + drift - size * .34, end + 7, x + drift + size * .9, end + 6, x + drift + size * .75, end - 2)
            ctx.bezierCurveTo(x + drift + size * .38, end * .65, x + size * .63, start + 11, x + size, start)
            ctx.closePath()
            ctx.fill()
            ctx.strokeStyle = "#757c2936"
            ctx.lineWidth = 1
            ctx.beginPath()
            ctx.moveTo(x - size * .28, start + 2)
            ctx.quadraticCurveTo(x + drift * .5, end * .5, x + drift, end - 6)
            ctx.stroke()
        }

        for (let i = 0; i < 32; ++i) {
            const reach = grain(i + 56)
            const x = 12 + (i / 32) * 193 + grain(i + 75) * 11
            const y = 4 + reach * reach * (107 - x * .32)
            const radius = Math.max(.65, (1 - x / 245) * (1 + grain(i + 120) * 6))
            ctx.beginPath()
            ctx.ellipse(x - radius, y - radius * .58, 2 * radius, radius * (1 + reach))
            ctx.fillStyle = i % 5 === 0 ? "#c9b0213d" : i % 3 ? "#905d0b20" : "#bd7c1325"
            ctx.fill()
            if (radius > 2.3) {
                ctx.beginPath()
                ctx.ellipse(x - radius * .45, y - radius * .38, radius * .7, radius * .32)
                ctx.fillStyle = "#8bea6371"
                ctx.fill()
            }
        }
    }
}

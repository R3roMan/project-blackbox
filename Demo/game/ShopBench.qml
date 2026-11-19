import QtQuick

Item {
    id: counter
    implicitHeight: 145
    property bool nativeScene: false
    property int detail:1
    property bool motion: true
    property var cards: []
    property string selectedId: ""
    Accessible.name: "Last Stop Supply, a bloodstained counter run by a skeleton"

    Canvas {
        anchors.fill: parent
        visible: !counter.nativeScene
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.scale(width / 748, height / 160)

            function box(x, y, w, h, top, bottom) {
                const color = bottom ? ctx.createLinearGradient(x, y, x, y + h) : null
                if (color) {
                    color.addColorStop(0, top)
                    color.addColorStop(1, bottom)
                }
                ctx.fillStyle = color || top
                ctx.fillRect(x, y, w, h)
            }
            function ellipse(x, y, rx, ry, color) {
                ctx.fillStyle = color
                ctx.beginPath()
                ctx.ellipse(x - rx, y - ry, rx * 2, ry * 2)
                ctx.fill()
            }
            function polygon(points, color, stroke) {
                ctx.beginPath()
                ctx.moveTo(points[0], points[1])
                for (let i = 2; i < points.length; i += 2)
                    ctx.lineTo(points[i], points[i + 1])
                ctx.closePath()
                ctx.fillStyle = color
                ctx.fill()
                if (stroke) {
                    ctx.strokeStyle = stroke
                    ctx.lineWidth = 1
                    ctx.stroke()
                }
            }
            function line(points, color, size) {
                ctx.strokeStyle = color
                ctx.lineWidth = size
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.beginPath()
                ctx.moveTo(points[0], points[1])
                for (let i = 2; i < points.length; i += 2)
                    ctx.lineTo(points[i], points[i + 1])
                ctx.stroke()
            }

            box(0, 0, 748, 160, "#101018", "#37232b")
            const lamp = ctx.createRadialGradient(234, 20, 4, 234, 20, 434)
            lamp.addColorStop(0, "#438e74")
            lamp.addColorStop(.52, "#214252")
            lamp.addColorStop(1, "#00312433")
            box(0, 0, 748, 129, lamp)
            for (let i = 0; i < 8; i += 1) {
                box(i * 108, 0, 4, 124, "#24131720")
                box(i * 108 + 4, 0, 1, 123, "#3846696e")
                ellipse(i * 108 + 8, 12, 2, 2, "#77807e")
            }
            for (let i = 0; i < 77; i += 1) {
                const x = (i * 147 + 13) % 748
                const y = 5 + (i * 59) % 110
                box(x, y, 2 + i % 4, 1 + i % 2, i % 3 ? "#335c3c46" : "#5853162a")
            }
            for (const drip of [[58,18,32],[386,72,57],[483,5,84],[697,17,76],[723,33,55],[461,66,32]]) {
                const [x, y, end] = drip
                ellipse(x, y, 16, 4, "#7c381626")
                line([x-2,y,x+3,y+9,x+3,y+end], "#9f54162e", 3)
                ellipse(x+3, y+end, 2, 3, "#a94e1729")
            }

            polygon([24,17,45,7,357,7,379,19,379,65,359,77,44,77,24,65], "#100e16", "#ad7856")
            polygon([30,20,48,13,356,13,373,22,373,61,356,70,48,70,30,61], "#293536", "#52777b")
            line([40,54,58,64,343,64,361,53], "#4c907d", 1.3)
            line([39,28,57,19,344,19,361,28], "#bd8960", 1)
            ellipse(46, 41, 4, 4, "#bb8467")
            ellipse(356, 41, 4, 4, "#bb8467")
            ellipse(83, 71, 22, 3, "#805f2334")

            // The chair stays upright while the skeleton falls to its left.
            line([545,101,551,31,629,26,638,108], "#120f17", 11)
            line([548,100,555,35,625,30,635,108], "#6b473c", 4)
            for (let i = 0; i < 3; i += 1)
                line([554,43+i*13,628,40+i*13], "#412d31", 5)
            box(538, 112, 108, 8, "#98674c", "#301f28")
            ctx.save()
            ctx.translate(590, 59)
            ctx.rotate(.32)
            polygon([-34,23,-25,7,-14,2,22,3,34,20,25,74,-28,80,-39,47], "#31242e", "#503641")
            line([-25,14,-38,24,-48,49,-36,57], "#352831", 11)
            line([22,12,40,33,49,38,63,24], "#322731", 12)
            line([-15,8,0,12,16,7], "#b3a18b", 4)
            line([1,-7,0,14,0,36,-4,47], "#bca998", 4)
            for (let i = 0; i < 5; i += 1) {
                const y = 16 + i * 5
                const rib = 22 - i * 2
                line([-rib,y-2,-rib+5,y+5,0,y+7,rib-3,y+4,rib,y-2], "#aa8c77", 2.5)
                line([-rib+4,y+3,0,y+7,rib-4,y+3], "#e2c4a2", 1)
            }
            line([-34,23,-45,46,-33,55], "#ae917c", 4)
            ellipse(-35, 55, 7, 3, "#ac8d78")
            line([23,14,41,37,54,36,62,26], "#bfa58a", 5)
            polygon([43,45,48,11,55,7,55,-5,65,-4,63,8,69,13,64,44], "#3d653a", "#9b9c5b")
            polygon([47,36,48,22,65,23,63,37], "#d7b466")
            box(54, -6, 11, 5, "#d6aea1", "#b15e49")
            line([49,22,46,28,49,33,56,34], "#d1b096", 3)
            polygon([-7,59,-20,53,-30,67,-42,89,-30,97,-6,73,10,70,16,97,29,100,28,71,21,55], "#41323a", "#66505a")
            ellipse(1, -13, 23, 23, "#9d826f")
            ellipse(-2, -17, 20, 21, "#d4bcb0")
            ellipse(-8, -24, 12, 8, "#f1d4b8")
            polygon([-16,-10,-11,6,-5,14,12,12,19,1,17,-11], "#bca28d")
            ellipse(-9, -11, 8, 6, "#271921")
            ellipse(10, -10, 7, 6, "#281a21")
            polygon([-1,-7,-5,0,4,0], "#3e2930")
            polygon([-8,4,-6,11,11,9,14,1,4,5], "#362831")
            for (let i = 0; i < 6; i += 1)
                box(-7+i*3, 3+(i%2), 1.7, 4, "#ead1ac", "#977664")
            line([11,-34,6,-26,15,-20,14,-17], "#6d504b", 1.2)
            line([-22,-13,-15,-19,-16,-23], "#674650", 1.5)
            ctx.restore()
            for (let i = 0; i < 18; i += 1) {
                const x = 570 + i * 19 % 159
                const y = 58 + i * 37 % 56
                ellipse(x,y,.65+i%3*.55,.65+i%2*.5,i%3 ? "#86988073" : "#c6bdaa8c")
            }

            polygon([0,114,30,97,663,97,748,112,748,127,0,127], "#885348", "#b78d69")
            polygon([0,114,748,114,748,159,0,159], "#392832", "#6d4a44")
            box(1, 117, 746, 7, "#97634d", "#4c282e")
            for (let i = 0; i < 16; i += 1) {
                const x = (i * 211) % 707
                line([x,132+i%17,x+32,131+i%17,x+41,132+i%17], "#66434a", 1)
            }
            for (const stain of [[91,112,54],[322,109,30],[431,117,64],[591,114,41],[704,111,35]]) {
                const [x,y,spread] = stain
                ellipse(x,y,spread,5,"#ab630b25")
                ellipse(x-8,y-1,spread*.67,3,"#cf8c1932")
                for (let i = 0; i < 6; i += 1) {
                    const dx = (i * 17) % spread - spread * .53
                    const fall = (i*13+spread)%38
                    line([x+dx,y,x+dx-2,y+8,x+dx-2,y+fall],"#804f1028",1+i%3)
                    ellipse(x+dx-2,y+fall,1+i%2,2,"#ab641128")
                }
            }

            // Scavenged hardware and a familiar eye charm on the counter.
            polygon([62,93,87,85,117,85,120,89,166,89,169,93,115,96,109,107,98,106,101,96,84,97,70,101,59,100],
                "#302c39", "#ba9a82")
            line([85,88,114,88,114,92,166,91], "#9a9d9a", 1.6)
            polygon([192,99,198,87,217,80,245,80,254,84,251,91,224,90,222,104,207,105,205,95],
                "#34292e", "#a98d76")
            line([217,82,247,82], "#c7b697", 1.2)
            for (let i = 0; i < 7; i += 1) {
                const x = 267+i*6
                box(x, 97-i%3, 3, 10+i%3, "#edbe69", "#71514e")
                ellipse(x+1.5,97-i%3,1.5,2,"#f5c684")
            }
            polygon([330,96,337,77,365,77,375,86,371,107,344,108], "#693a77", "#ca80a9")
            polygon([330,96,337,80,362,81,357,99,344,105], "#8f477e")
            line([348,106,352,86,366,78], "#ffbf67", 3)
            line([336,86,365,93,372,91], "#e08e58", 2.5)
            line([352,88,345,72,352,74,356,83,365,71,367,77,352,88], "#ffd17b", 1.7)
            polygon([405,107,410,85,416,83,416,75,424,76,423,84,429,90,427,107], "#58492d", "#a08153")
            box(410, 94, 17, 6, "#bf9b62", "#85664d")
            ellipse(474, 103, 13, 6, "#492536")
            ellipse(474, 102, 8, 3, "#b9698e")
            ellipse(475, 102, 2, 3, "#fbc58c")
            box(0, 157, 748, 2, "#97584f")
        }
    }
    Loader {
        anchors.fill: parent
        active: counter.nativeScene
        sourceComponent: ShopCounter3D {
            cards: counter.cards
            selectedId: counter.selectedId
            motion: counter.motion
            detail:counter.detail
        }
    }

    Text {
        x: counter.width * .083
        y: counter.height * .155
        width: counter.width * .38
        height: counter.height * .195
        text: "LAST STOP SUPPLY"
        font.family: "Archivo Black"
        font.bold: true
        font.pixelSize: Math.min(counter.height * .18, width * .077)
        font.letterSpacing: 1.25
        color: "#ffe0a1"
        style: Text.Outline
        styleColor: "#44252d"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}

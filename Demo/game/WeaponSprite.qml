import QtQuick
import "WeaponArt.js" as Art
import "MeleeArt.js" as Blade

Item {
    id: sprite
    objectName: "weaponSprite"

    required property var weapon
    required property real shotLife
    property real reloadRatio: 0
    property real rotaryAngle: 0
    property bool primed: false
    property bool bayonet: false
    property real stab: 0
    property int sequence: 0
    property int combo: 0
    property real staffCharge: 0
    property real staffCast:0
    property real clock: 0
    property point aimOffset: Qt.point(0,0)
    property bool catalogue: false
    required property bool motion
    readonly property bool handWeapon: !!weapon.melee || !!weapon.throwing || !!weapon.stab
    readonly property bool staff: !!weapon.staff
    readonly property string pattern: weapon.id === "kingsRansom" || weapon.id === "graduate" ? "pistol" : weapon.id === "stillwater" ? "rail" : weapon.id === "siegeRpg" ? "launcher" : weapon.art || weapon.id
    readonly property bool twins: pattern === "twinpistols" || !!weapon.dual
    readonly property real intensity: Math.min(1, shotLife / weapon.afterglow)
    readonly property var bladePose: Blade.pose(pattern, motion ? intensity : 0, motion ? reloadRatio : 0, combo, sequence)
    readonly property color accent: weapon.color
    readonly property var art: Art.design(weapon)
    readonly property var pose: Art.pose(art, motion ? Math.min(1, shotLife / weapon.afterglow) : 0,
        motion ? reloadRatio : 0, rotaryAngle)
    readonly property real kick: pose.rear
    readonly property point muzzle: {
        pose
        if (handWeapon)
            return steel.mapToItem(sprite,steel.width*.06,steel.height*.34)
        if (staff)
            return Qt.point(width * .28, height * .27)
        if (twins)
            return Qt.point(width * (sequence % 2 ? .11 : .49), height * (sequence % 2 ? .36 : .54))
        return rig.mapToItem(sprite, design.tip[0] * width / 336, design.tip[1] * height / 150)
    }

    // Each silhouette shares a left-facing muzzle and a hand-end at the right of the canvas.
    readonly property var designs: ({
        pistol: { tip: [64, 54], metal: "#576477", ports: [139, 160, 181], shell:
            [64, 44, 127, 39, 166, 42, 175, 37, 266, 40, 279, 55, 268, 71, 254, 77,
             265, 109, 304, 128, 336, 130, 336, 150, 243, 150, 223, 132, 223, 101, 199, 82, 126, 74, 64, 64] },
        scattergun: { tip: [18, 51], metal: "#745346", ports: [142, 162, 182, 202], shell:
            [18, 40, 143, 41, 154, 50, 227, 50, 253, 65, 274, 74, 312, 95, 336, 121,
             336, 150, 280, 150, 251, 114, 218, 100, 206, 87, 130, 85, 108, 75, 18, 64] },
        carbine: { tip: [37, 49], metal: "#526350", ports: [127, 144, 161, 178], shell:
            [37, 38, 99, 38, 103, 32, 151, 32, 161, 26, 217, 29, 237, 40, 283, 47, 336, 74,
             336, 150, 302, 150, 271, 113, 251, 102, 230, 134, 195, 134, 187, 91, 132, 84, 119, 68, 37, 61] },
        rail: { tip: [12, 47], metal: "#475f78", ports: [103, 121, 139, 157, 175], shell:
            [12, 37, 144, 35, 170, 27, 252, 24, 270, 32, 283, 51, 320, 66, 336, 82,
             336, 150, 280, 150, 243, 115, 208, 120, 191, 85, 151, 76, 128, 62, 12, 57] },
        riot: { tip: [17, 52], metal: "#767e69", ports: [90, 111, 132, 153, 174], shell:
            [17, 37, 128, 37, 141, 31, 197, 32, 218, 48, 278, 53, 323, 68, 336, 86,
             336, 150, 277, 150, 251, 120, 231, 106, 194, 96, 164, 103, 124, 94, 113, 72, 17, 66] },
        ion: { tip: [62, 55], metal: "#426a6e", ports: [121, 135, 149, 163, 177, 191], shell:
            [62, 42, 115, 34, 143, 24, 181, 22, 217, 28, 245, 43, 285, 49, 309, 64, 336, 89,
             336, 150, 273, 150, 248, 112, 235, 115, 220, 140, 180, 132, 168, 104, 111, 84, 62, 66] },
        hellbore: { tip: [13, 51], metal: "#773e48", ports: [156, 176, 196], shell:
            [13, 30, 137, 32, 151, 22, 192, 26, 213, 44, 254, 47, 270, 63, 321, 89, 336, 104,
             336, 150, 267, 150, 239, 116, 211, 111, 185, 94, 138, 86, 117, 76, 13, 71] },
        arc: { tip: [37, 53], metal: "#645184", ports: [113, 130, 147, 164, 181], shell:
            [37, 46, 83, 32, 114, 34, 149, 19, 200, 20, 222, 30, 247, 36, 258, 49, 303, 63, 336, 90,
             336, 150, 289, 150, 260, 117, 230, 107, 206, 127, 170, 119, 153, 97, 103, 81, 83, 64, 37, 59] },
        lance: { tip: [10, 46], metal: "#4e62a1", ports: [72, 96, 120, 144, 168, 192], shell:
            [10, 43, 70, 31, 130, 29, 153, 17, 219, 17, 240, 29, 275, 33, 312, 55, 336, 63,
             336, 150, 285, 150, 249, 117, 217, 97, 185, 110, 165, 95, 145, 73, 71, 65, 10, 51] },
        solar: { tip: [15, 47], metal: "#775c39", ports: [86, 105, 124, 143, 162, 181], shell:
            [15, 41, 65, 33, 83, 20, 117, 24, 157, 10, 204, 15, 231, 26, 271, 36, 302, 54, 336, 57,
             336, 150, 273, 150, 242, 116, 208, 113, 179, 124, 159, 102, 152, 81, 112, 72, 82, 77, 61, 60, 15, 55] },
        dread: { tip: [13, 55], metal: "#6c4942", ports: [91, 111, 131, 151, 171], shell:
            [13, 24, 67, 20, 93, 30, 188, 30, 208, 20, 250, 23, 274, 42, 312, 42, 336, 57,
             336, 150, 280, 150, 255, 121, 222, 114, 199, 95, 92, 101, 68, 89, 13, 82] },
        crucible: { tip: [22, 63], metal: "#74426d", ports: [109, 129, 149, 169, 189, 209], shell:
            [22, 58, 65, 38, 97, 31, 133, 17, 183, 19, 219, 30, 265, 34, 291, 52, 336, 69,
             336, 150, 290, 150, 264, 130, 222, 118, 199, 147, 171, 132, 152, 108, 109, 101, 91, 84, 22, 72] }
        ,
        minigun: { tip:[47,51], metal:"#696677", ports:[110,134,159,184,216], shell:
            [47,36,103,34,104,24,174,22,200,9,246,16,270,30,302,39,336,62,336,150,
             237,150,203,128,147,132,131,100,93,77,47,70] },
        launcher: { tip:[16,48], metal:"#777050", ports:[93,120,147,175], shell:
            [16,31,135,25,164,31,206,24,256,35,282,50,308,54,336,78,336,150,256,150,
             221,119,152,134,115,110,111,80,71,70,16,67] },
        breacher: { tip:[25,55], metal:"#746456", ports:[119,142,180], shell:
            [25,39,114,28,177,28,216,39,253,39,275,68,336,89,336,150,271,150,
             241,121,207,114,179,80,143,82,112,76,25,72] },
        volt: { tip:[41,54], metal:"#427875", ports:[92,115,149,182,201], shell:
            [41,30,117,11,180,24,200,35,257,34,275,49,320,59,336,77,336,150,278,150,
             237,117,211,114,208,133,170,127,154,92,118,86,76,68,41,72] },
        razor: { tip:[28,48], metal:"#507989", ports:[117,143,169], shell:
            [28,31,87,31,105,23,153,23,172,14,235,24,247,40,289,37,336,61,336,150,
             287,150,256,115,228,110,214,144,173,143,165,105,128,92,103,72,28,68] },
        ember: { tip:[18,59], metal:"#8c543d", ports:[113,141,161,191], shell:
            [18,36,65,25,174,26,203,14,249,31,267,50,307,57,336,82,336,150,276,150,
             246,126,201,122,168,101,101,105,63,91,18,80] },
        harrier: { tip:[9,49], metal:"#627d56", ports:[85,106,129,153,174,192], shell:
            [9,41,64,34,92,25,146,24,175,20,202,11,245,23,266,37,303,44,336,64,
             336,150,282,150,242,115,206,108,188,90,128,84,103,71,61,58,9,56] },
        prism: { tip:[17,54], metal:"#597f8c", ports:[72,104,132,163,194,210], shell:
            [17,43,60,24,106,26,131,13,183,18,229,26,247,41,285,40,306,56,336,67,
             336,150,292,150,276,125,239,108,208,113,183,138,143,123,125,92,77,76,17,67] },
        cyclone: { tip:[33,55], metal:"#705289", ports:[99,125,147,176,204,228], shell:
            [33,33,84,27,124,20,154,25,175,6,226,11,275,28,295,43,336,64,336,150,
             257,150,227,136,209,116,155,142,117,134,99,96,74,81,33,77] },
        redline: { tip:[6,48], metal:"#625b66", ports:[101,118,141,164,186], shell:
            [6,40,64,37,86,29,137,27,137,13,159,9,202,14,207,27,248,22,278,40,336,64,336,150,
             293,150,251,106,206,110,166,133,141,125,126,83,95,78,62,58,6,55] },
        tesla: { tip:[21,56], metal:"#514067", ports:[108,129,147,167,195,220], shell:
            [21,38,62,27,116,33,141,14,208,12,254,19,291,45,336,54,336,150,278,150,
             245,127,205,128,183,140,140,112,115,85,51,81,21,73] },
        pyre: { tip:[26,59], metal:"#79432e", ports:[75,96,127,147,166,187], shell:
            [26,34,60,28,102,18,155,20,208,18,270,43,336,64,336,150,275,150,237,127,210,139,165,140,
             144,113,115,106,86,84,26,81] },
        glacier: { tip:[15,49], metal:"#557d9c", ports:[113,139,168,193,213], shell:
            [15,36,65,29,99,33,122,22,173,10,207,13,239,25,264,18,281,34,314,44,336,64,336,150,
             262,150,245,120,195,131,147,125,128,99,88,88,66,70,15,65] },
        shrapnel: { tip:[22,53], metal:"#746044", ports:[90,121,172], shell:
            [22,28,77,20,119,32,150,14,185,20,210,10,254,29,287,33,336,67,336,150,
             273,150,238,119,192,124,170,144,126,133,103,104,75,93,22,81] },
        bilecaster: { tip:[31,58], metal:"#53613c", ports:[83,105,124,235], shell:
            [31,35,62,35,83,46,135,38,144,15,218,15,240,36,278,44,306,58,336,84,336,150,
             284,150,247,109,222,106,203,134,163,129,152,101,111,95,78,78,31,80] },
        furnacebeam: { tip:[19,51], metal:"#783641", ports:[51,73,97,123,151,177,210,231], shell:
            [19,26,66,14,108,31,144,22,208,23,245,37,280,61,336,74,336,150,262,150,234,114,184,130,163,121,
             147,93,119,88,84,92,56,78,19,76] },
        kestrel: { tip:[31,51], metal:"#53694f", ports:[99,129,159,181], shell:
            [31,38,99,35,118,24,180,25,206,36,249,35,273,58,315,65,336,85,336,150,268,150,246,122,
             190,106,159,123,126,109,110,88,31,69] },
        deadeye: { tip:[8,51], metal:"#776050", ports:[82,116,141,177], shell:
            [8,45,78,39,100,29,128,30,137,15,201,15,220,27,240,29,275,53,318,58,336,77,336,150,
             277,150,250,121,224,107,178,123,146,112,125,84,93,72,8,58] },
        blackHole: { tip:[42,56], metal:"#443552", ports:[113,147,179,212], shell:
            [29,28,64,19,96,33,113,47,153,32,209,29,265,40,287,55,321,62,336,78,336,150,263,150,
             232,130,192,136,168,107,120,89,89,80,63,94,33,80,17,59] },
        starDestroyer: { tip:[10,55], metal:"#ab742e", ports:[61,83,104,125,146,167,188,210,231], shell:
            [10,26,51,19,88,31,118,14,152,23,178,7,207,11,248,22,273,39,310,36,336,56,336,150,
             269,150,236,121,219,133,176,139,155,122,133,102,112,99,98,87,53,95,10,82] },
        starDestroyerPlus: { tip:[11,54], metal:"#c79032", ports:[67,88,106,130,147,170,190,216,249], shell:
            [11,20,47,12,74,29,106,17,146,8,183,12,210,8,239,18,263,14,278,35,310,29,336,53,336,150,
             278,150,240,118,209,131,167,142,142,120,113,112,99,98,69,106,44,89,11,83] }
    })
    readonly property var design: {
        const alias = ({kingsRansom:"pistol",stillwater:"rail",breakwater:"harrier",nightInk:"crucible",echosix:"pistol",
            riftScatter:"riot",siltCarbine:"carbine",rimeRelay:"glacier",whiteoutCoil:"prism",jesterScatter:"prism"})[pattern]
        const base = designs[pattern] || designs[alias] || designs.pistol
        if (alias)
            return Object.assign({},base,{metal:art.shell})
        return !weapon.frame ? base : Object.assign({},base,{ metal:art.shell,
            shell:base.shell.map(function(point,index) {
                return index % 2 ? 69 + (point-69) * (1 + (weapon.frame % 7 - 3)*.046)
                    : 336 + (point-336) * (1 + (weapon.frame % 6 - 2.5)*.034)
            })
        })
    }

    Item {
        id: rig
        anchors.fill: parent
        visible: !sprite.handWeapon && !sprite.twins && !sprite.staff
        transform: [
            Translate { x: sprite.kick - sprite.stab * 54; y: -sprite.pose.rise + sprite.pose.shellTravel * .13 - sprite.stab * 19 },
            Rotation { origin.x: sprite.width * .78; origin.y: sprite.height * .60; angle: sprite.pose.roll * .47 }
        ]

        Canvas {
            anchors.fill: parent
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections {
                target: sprite
                function onDesignChanged() { parentCanvas.requestPaint() }
                function onBayonetChanged() { parentCanvas.requestPaint() }
            }
            id: parentCanvas
            Connections {
                target: sprite
                function onRotaryAngleChanged() { if (sprite.weapon.spinup) parentCanvas.requestPaint() }
            }

            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.scale(width / 336, height / 150)
                const design = sprite.design
                const shell = design.shell
                ctx.beginPath()
                ctx.moveTo(shell[0], shell[1])
                for (let index = 2; index < shell.length; index += 2)
                    ctx.lineTo(shell[index], shell[index + 1])
                ctx.closePath()
                const metal = ctx.createLinearGradient(0, 15, 65, 133)
                metal.addColorStop(0, Qt.lighter(design.metal, 1.5))
                metal.addColorStop(.40, design.metal)
                metal.addColorStop(.55, Qt.darker(design.metal, 1.22))
                metal.addColorStop(1, "#181721")
                ctx.fillStyle = metal
                ctx.fill()
                ctx.strokeStyle = "#111016"
                ctx.lineWidth = 4
                ctx.stroke()

                ctx.save()
                ctx.clip()
                ctx.fillStyle = "#191721"
                ctx.fillRect(design.tip[0] - 2, design.tip[1] - 12, 15, 24)
                ctx.fillRect(design.tip[0] + 10, design.tip[1] + 12, 240, 3)
                ctx.fillStyle = Qt.lighter(design.metal, 1.45)
                ctx.fillRect(design.tip[0] + 18, design.tip[1] - 10, 209, 2)
                for (const x of design.ports) {
                    ctx.fillStyle = "#201d27"
                    ctx.fillRect(x, 46, 9, 17)
                    ctx.fillStyle = sprite.accent
                    ctx.fillRect(x + 2, 49, 3, 10)
                }
                ctx.strokeStyle = "#282530"
                ctx.lineWidth = 3
                for (let line = 0; line < 6; line += 1) {
                    ctx.beginPath()
                    ctx.moveTo(248 + line * 12, 93)
                    ctx.lineTo(266 + line * 12, 144)
                    ctx.stroke()
                }
                ctx.restore()
                if (sprite.bayonet) {
                    ctx.beginPath()
                    ctx.moveTo(design.tip[0] + 27, design.tip[1] + 8)
                    ctx.lineTo(Math.max(1, design.tip[0] - 57), design.tip[1] + 17)
                    ctx.lineTo(design.tip[0] + 12, design.tip[1] + 27)
                    ctx.lineTo(design.tip[0] + 48, design.tip[1] + 20)
                    ctx.closePath()
                    ctx.fillStyle = "#c3d6e0"
                    ctx.fill()
                    ctx.strokeStyle = "#313645"
                    ctx.lineWidth = 3
                    ctx.stroke()
                }
                if (sprite.weapon.id === "bilecaster") {
                    const rise = sprite.pose.shellTravel * .35
                    ctx.fillStyle = "#252e22"
                    ctx.fillRect(143, 17 - rise, 86, 30)
                    ctx.fillStyle = sprite.accent
                    ctx.fillRect(155, 22 - rise, 62, 18)
                    ctx.fillStyle = "#e4ffbb"
                    ctx.fillRect(155, 23 - rise, 62, 4)
                }
                if (sprite.weapon.id === "blackHole") {
                    ctx.fillStyle = "#10091a"
                    ctx.strokeStyle = sprite.accent
                    ctx.lineWidth = 3
                    ctx.beginPath()
                    ctx.ellipse(26,28,32,54)
                    ctx.fill()
                    ctx.stroke()
                    ctx.strokeStyle = "#fbe5ff"
                    ctx.lineWidth = 1.3
                    ctx.beginPath()
                    ctx.ellipse(21,24,42,62)
                    ctx.stroke()
                }
                if (sprite.weapon.id === "jesterScatter") {
                    const colors = ["#fb6383","#ffd46e","#b1fa82","#5eeaff","#9867ff","#f88ddd"]
                    for (let i=0; i<colors.length; ++i) {
                        ctx.beginPath()
                        ctx.moveTo(62+i*30,41)
                        ctx.lineTo(78+i*30,35)
                        ctx.lineTo(89+i*30,63)
                        ctx.lineTo(72+i*30,70)
                        ctx.closePath()
                        ctx.fillStyle=colors[i]
                        ctx.fill()
                    }
                }
                if (sprite.weapon.id === "nightInk" || sprite.weapon.id === "whiteoutCoil" || sprite.weapon.id === "rimeRelay") {
                    ctx.fillStyle = sprite.weapon.id === "nightInk" ? "#120924" : "#76bdde"
                    ctx.strokeStyle = sprite.accent
                    ctx.lineWidth = 2.5
                    ctx.beginPath()
                    ctx.ellipse(105,27,77,32)
                    ctx.fill()
                    ctx.stroke()
                }
                if (sprite.weapon.spinup) {
                    const rx = design.tip[0] + 7
                    const ry = design.tip[1]
                    for (let i = 0; i < 6; i += 1) {
                        const angle = (sprite.rotaryAngle + i * 60) * Math.PI / 180
                        ctx.fillStyle = sprite.accent
                        ctx.fillRect(rx + Math.cos(angle) * 10, ry + Math.sin(angle) * 13, 3.3, 3.3)
                    }
                }
            }
        }

        Canvas {
            x: sprite.design.tip[0] * sprite.width / 336 - width * .92
            y: sprite.design.tip[1] * sprite.height / 150 - height / 2
            width: sprite.weapon.effect === "rocket" ? 84 : 63
            height: width * .72
            visible: sprite.shotLife > 0
            opacity: Math.min(1, sprite.shotLife / sprite.weapon.afterglow * 1.55)
            onVisibleChanged: if (visible) requestPaint()
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                ctx.scale(width, height)
                const flare = [.01, .5, .33, .34, .20, .08, .60, .27, .77, .02, .88, .34,
                    .99, .5, .89, .66, .77, .98, .60, .72, .20, .92, .34, .65]
                ctx.beginPath()
                ctx.moveTo(flare[0], flare[1])
                for (let index = 2; index < flare.length; index += 2)
                    ctx.lineTo(flare[index], flare[index + 1])
                ctx.closePath()
                ctx.fillStyle = sprite.accent
                ctx.fill()
                ctx.fillStyle = "#fff6d7"
                ctx.fillRect(.47, .46, .48, .085)
            }
        }
    }
    StaffSprite {
        objectName: "heldStaffSprite"
        anchors.fill: parent
        visible: sprite.staff
        catalogue:sprite.catalogue
        kind: sprite.weapon.staff ? sprite.weapon.staff.kind : ""
        tint: sprite.accent
        charge: sprite.staffCharge
                cast:sprite.staffCast
        clock: sprite.staff && sprite.motion ? sprite.clock : 0
        attack: sprite.staff ? sprite.intensity : 0
    }
    MeleeSprite {
        id: steel
        objectName: "heldMeleeSprite"
        readonly property real unit: Math.min(sprite.width/560,sprite.height/482)
        readonly property real angle: rotation*Math.PI/180
        readonly property real halfSpan: (Math.abs(Math.sin(angle))*width+Math.abs(Math.cos(angle))*height)*.5
        width: sprite.catalogue ? sprite.width : Math.min(sprite.width*.72,sprite.height*.67)
        height: width*170/336
        x: sprite.width*.5-width*.5 + (sprite.catalogue ? 0 : unit*sprite.bladePose.x)
        y: sprite.catalogue ? (sprite.height-height)*.5 : Math.max(halfSpan+4,Math.min(sprite.height-halfSpan-6,
            sprite.height*.5-unit*(sprite.bladePose.y*.70+29)))-height*.5
        visible: sprite.handWeapon && (!sprite.weapon.throwing || sprite.intensity < .47)
        weaponId: sprite.pattern
        accent: sprite.accent
        primed: sprite.primed
        action: sprite.bladePose.inner
        clock: sprite.weapon.stab && sprite.motion ? sprite.clock : 0
        spin: sprite.rotaryAngle
        rotation: sprite.catalogue ? 0 : 77-sprite.bladePose.roll-sprite.aimOffset.x*6+(84-sprite.bladePose.pitch)*.46
    }
    Canvas {
        id: pair
        anchors.fill: parent
        visible: sprite.twins
        onVisibleChanged: if (visible) requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: sprite
            function onSequenceChanged() { if (pair.visible) pair.requestPaint() }
            function onIntensityChanged() { if (pair.visible) pair.requestPaint() }
            function onReloadRatioChanged() { if (pair.visible) pair.requestPaint() }
            function onBayonetChanged() { if (pair.visible) pair.requestPaint() }
            function onStabChanged() { if (pair.visible) pair.requestPaint() }
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            ctx.scale(width / 336, height / 150)
            const handgun = sprite.designs.pistol
            for (let i = 0; i < 2; i += 1) {
                const recoil = sprite.sequence % 2 === 1 - i ? sprite.intensity : 0
                ctx.save()
                ctx.translate(-11 + i*127 + recoil*11 - sprite.stab*27, 11 + i*23 + sprite.pose.shellTravel*.32)
                ctx.scale(.70, .94)
                ctx.rotate((i ? .055 : -.082) * (1 + sprite.pose.shellTravel*.07))
                ctx.beginPath()
                ctx.moveTo(handgun.shell[0], handgun.shell[1])
                for (let j = 2; j < handgun.shell.length; j += 2)
                    ctx.lineTo(handgun.shell[j], handgun.shell[j+1])
                ctx.closePath()
                ctx.fillStyle = i ? "#8b7977" : "#77646b"
                ctx.fill()
                ctx.lineWidth = 4
                ctx.strokeStyle = "#221d2b"
                ctx.stroke()
                ctx.fillStyle = "#cab1a1"
                ctx.fillRect(66, 48, 134, 5)
                ctx.fillStyle = "#312734"
                ctx.fillRect(68, 57, 86, 11)
                if (i && sprite.bayonet) {
                    ctx.beginPath()
                    ctx.moveTo(83, 65)
                    ctx.lineTo(10, 73)
                    ctx.lineTo(76, 84)
                    ctx.fillStyle = "#c3d6e0"
                    ctx.fill()
                }
                if (recoil > .1) {
                    ctx.globalAlpha = recoil
                    ctx.fillStyle = "#fff0c2"
                    ctx.beginPath()
                    ctx.ellipse(47,50,31,18)
                    ctx.fill()
                    ctx.globalAlpha = 1
                }
                ctx.restore()
            }
        }
    }
}

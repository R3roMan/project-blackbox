import QtQuick
import "WeaponArt.js" as Art

Item {
    id: feedback

    required property var weapon
    required property var rays
    required property real life
    required property point pointer
    required property point muzzle
    required property bool aiming
    required property bool cycling
    required property real readiness
    required property bool turning
    required property bool stunned
    required property real sealProgress
    property real spreadMultiplier: 1
    property bool sustained: false
    property bool chargedSlash: false
    property int combo: 0
    property bool scoped: false
    property color tracerColor: weapon.color
    property bool coinShot:false
    property real muzzleLife:0
    property bool motion:true
    property int sequence:0
    property bool ultra:false
    property real clock:0
    property int nextCasing:0
    property real lastCasingTime:-1

    readonly property bool scatter: weapon.effect === "spread"
    readonly property bool beam: weapon.effect === "beam" || weapon.effect === "laser"
    readonly property bool pulse: weapon.effect === "pulse" || weapon.effect === "burst"
    readonly property bool carbine: weapon.effect === "tracer"
    readonly property bool rocket: weapon.effect === "rocket"
    readonly property bool ink: weapon.id === "nightInk"
    readonly property color paint: tracerColor
    readonly property real fade: sustained ? .90 : Math.min(1, life / weapon.afterglow)

    function ejectCase(spec, shot, barrel, grip) {
        const form = Art.design(spec).form
        if (!["slide", "box", "rotary", "pump", "break"].includes(form)
                && !(form === "rail" && spec.effect === "tracer"))
            return
        const casing = casings.itemAt(nextCasing)
        if (!casing)
            return
        nextCasing = (nextCasing + 1) % casings.count
        casing.side = spec.dual || spec.id === "twinpistols" ? (barrel.x < grip.x ? -1 : 1) : 1
        casing.origin = Qt.point(barrel.x * .47 + grip.x * .53 + casing.side * height * .034,
            barrel.y * .47 + grip.y * .53)
        casing.shot = shot
        casing.shell = spec.effect === "spread"
        casing.born = clock
        lastCasingTime = clock
    }

    onVisibleChanged: if (!visible) clearCases()
    onClockChanged: if (clock < lastCasingTime) clearCases()

    function clearCases() {
        for (let i=0; i<casings.count; ++i) {
            const casing = casings.itemAt(i)
            if (casing)
                casing.born = -1
        }
        nextCasing = 0
        lastCasingTime = -1
    }

    Repeater {
        model: (feedback.life > 0 || feedback.sustained) && !feedback.weapon.melee && !feedback.weapon.throwing
            && feedback.weapon.effect !== "grenade" ? feedback.rays : []
        delegate: Item {
            id: trail
            required property var modelData
            readonly property real muzzleX: feedback.muzzle.x
            readonly property real muzzleY: feedback.muzzle.y
            readonly property real endX: feedback.sustained ? feedback.pointer.x + (modelData.dx || 0) : modelData.x
            readonly property real endY: feedback.sustained ? feedback.pointer.y + (modelData.dy || 0) : modelData.y
            readonly property real dx: endX - muzzleX
            readonly property real dy: endY - muzzleY
            readonly property real length: Math.sqrt(dx * dx + dy * dy)
            readonly property real head: feedback.carbine ? .65 : feedback.pulse ? .46
                : feedback.beam || feedback.scatter || feedback.rocket ? 0 : .31

            Rectangle {
                x: trail.muzzleX + trail.dx * trail.head
                y: trail.muzzleY + trail.dy * trail.head
                width: trail.length * (1 - trail.head)
                height: feedback.weapon.trace + (feedback.beam || feedback.rocket || feedback.ink ? 9 : 3)
                rotation: Math.atan2(trail.dy, trail.dx) * 180 / Math.PI
                transformOrigin: Item.Left
                color: Qt.rgba(feedback.paint.r, feedback.paint.g, feedback.paint.b,
                    feedback.ink ? .70 : feedback.beam || feedback.rocket ? .39 : .25)
                opacity: feedback.fade
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: feedback.weapon.trace + (feedback.ink ? 4 : 0)
                    color: feedback.ink ? "#100916" : feedback.beam ? "#fffce7" : feedback.paint
                }
            }
            Rectangle {
                id:coinTrail
                visible:feedback.coinShot
                readonly property real travel:1-feedback.fade
                x:trail.muzzleX+trail.dx*travel-width/2
                y:trail.muzzleY+trail.dy*travel-height/2
                width:23-travel*11
                height:width
                radius:width/2
                scale:1+Math.sin(travel*Math.PI)*.25
                transform:Scale {origin.x:11; xScale:.22+Math.abs(Math.cos(coinTrail.travel*28))*.78}
                opacity:feedback.fade
                gradient:Gradient {
                    GradientStop {position:0; color:"#fff7b4"}
                    GradientStop {position:.42; color:"#ffe174"}
                    GradientStop {position:1; color:"#9c6720"}
                }
                border.color:"#ffecac"
                border.width:2
                Text {anchors.centerIn:parent; text:"¤"; color:"#795020"; font.pixelSize:parent.height*.76; font.bold:true}
            }
            Rectangle {
                readonly property real diameter: feedback.rocket ? 60 - feedback.fade * 39
                    : feedback.ink ? 16 : feedback.beam ? 25 - feedback.fade * 12 : feedback.pulse ? 13 : feedback.scatter ? 7 : 9
                x: trail.endX - diameter / 2
                y: trail.endY - diameter / 2
                width: diameter
                height: diameter
                radius: diameter / 2
                opacity: feedback.fade
                color: feedback.ink ? "#0c0710" : feedback.beam || feedback.rocket ? "transparent" : feedback.paint
                border.color: trail.modelData.hit ? "#fff8dc" : feedback.paint
                border.width: feedback.beam || feedback.rocket ? 2 : 1
            }
        }
    }

    MuzzleBlast {weapon:feedback.weapon;tint:feedback.paint;tip:feedback.muzzle;aim:feedback.pointer
        life:feedback.muzzleLife;motion:feedback.motion;sequence:feedback.sequence;ultra:feedback.ultra}

    Repeater {
        id:casings
        model:feedback.ultra && feedback.motion ? 12 : 0
        delegate:Item {
            id:casing
            property real born:-1
            property point origin
            property int side:1
            property int shot:0
            property bool shell:false
            readonly property real age:born < 0 ? 1 : (feedback.clock-born)/.54
            readonly property real spread:Math.min(124,feedback.height*.145)
            readonly property real roll:Math.cos(age*13+shot*2.7)
            width:Math.max(9,Math.min(22,feedback.height*(shell ? .024 : .019)))
            height:width*(shell ? .43 : .34)
            visible:age>=0 && age<1
            opacity:Math.min(1,(1-age)*3.7)
            x:origin.x+side*age*spread*(1.11+shot%5*.094)-width/2
            y:origin.y+spread*(age*age*1.64-age*(.84+shot%3*.15))-height/2
            rotation:side*(shot*37+age*(226+shot%5*34))
            transform:Scale {origin.x:casing.width/2; xScale:.31+Math.abs(casing.roll)*.69}

            Rectangle {
                anchors.fill:parent
                radius:1.2
                gradient:Gradient {
                    GradientStop {position:0;color:casing.shell ? "#ff974e" : "#fff3b3"}
                    GradientStop {position:.34;color:casing.shell ? "#d65330" : "#d5a24c"}
                    GradientStop {position:1;color:casing.shell ? "#66231f" : "#624022"}
                }
            }
            Rectangle {
                width:parent.width*.20;height:parent.height+1
                y:-.5;color:"#ffcf77";radius:1
                border.width:1;border.color:"#815729"
            }
            Rectangle {
                anchors.right:parent.right
                width:parent.width*.16;height:parent.height
                radius:1;color:"#62432d";border.width:1;border.color:"#bc9454"
            }
            Rectangle {
                x:parent.width*.25;y:parent.height*.13
                width:parent.width*.44;height:Math.max(1,parent.height*.18)
                color:"#fff8d6";opacity:Math.abs(casing.roll)*.72
            }
        }
    }

    Canvas {
        id: bladeTrail
        anchors.fill: parent
        visible: !!feedback.weapon.melee && feedback.life > 0
        onVisibleChanged: if (visible) requestPaint()
        Connections {
            target: feedback
            function onLifeChanged() { if (bladeTrail.visible) bladeTrail.requestPaint() }
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)
            const advance = 1 - feedback.fade
            const powered = feedback.chargedSlash
            const x = feedback.pointer.x
            const y = feedback.pointer.y
            const reach = (powered ? .26 : .17) * height * (.67 + advance * .50)
            ctx.globalAlpha = Math.min(.92, feedback.fade * 1.3)
            ctx.strokeStyle = feedback.weapon.color
            ctx.lineWidth = powered ? 17 : feedback.weapon.id === "chainsaw" ? 9 : 11
            ctx.beginPath()
            if (feedback.weapon.id === "katana" && feedback.combo === 3) {
                ctx.moveTo(x + reach*.43, y - reach*1.12)
                ctx.quadraticCurveTo(x - reach*.32, y - reach*.24, x - reach*.40, y + reach)
            } else if (feedback.weapon.id === "katana" && feedback.combo === 2) {
                ctx.moveTo(x + reach, y + reach*.07)
                ctx.quadraticCurveTo(x + reach*.08, y - reach*.43, x - reach, y - reach*.07)
            } else {
                ctx.moveTo(x - reach, y + reach * .59)
                ctx.quadraticCurveTo(x - reach * .09, y - reach * .68, x + reach, y - reach * .46)
            }
            ctx.stroke()
            ctx.strokeStyle = "#fff4e2"
            ctx.lineWidth = powered ? 5 : 2
            ctx.stroke()
            for (let i = 0; i < 9; i += 1) {
                const phase = i / 9
                const sparkX = x + (phase * 2 - 1) * reach
                const sparkY = y - Math.sin(phase * Math.PI * .73) * reach * .39 + advance * ((i % 3 - 1) * 24)
                ctx.fillStyle = i % 2 ? feedback.weapon.color : "#ffdca8"
                ctx.fillRect(sparkX, sparkY, (1 - advance) * (i % 3 + 2) + 1, 3)
            }
        }
    }

    Item {
        id: crosshair
        objectName: "weaponReticle"
        width: feedback.scatter || feedback.weapon.melee
            ? Math.max(feedback.weapon.aim, feedback.height * feedback.weapon.aim / 650) * feedback.spreadMultiplier : feedback.weapon.aim
        height: width
        x: feedback.pointer.x - width / 2
        y: feedback.pointer.y - height / 2
        visible: feedback.aiming && !feedback.scoped
        opacity: feedback.turning ? .42 : 1
        readonly property color ink: feedback.stunned ? "#fa819b" : feedback.weapon.color

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.color: crosshair.ink
            border.width: feedback.beam ? 2 : 1
        }
        Rectangle {
            anchors.centerIn: parent
            width: parent.width * (feedback.beam ? .56 : .62)
            height: width
            radius: width / 2
            color: "transparent"
            border.color: crosshair.ink
            opacity: .58
            visible: feedback.beam || feedback.scatter || feedback.pulse
        }
        Repeater {
            model: feedback.carbine ? 4 : 0
            delegate: Rectangle {
                required property int index
                width: index % 2 === 0 ? 2 : 6
                height: index % 2 === 0 ? 6 : 2
                x: crosshair.width / 2 - width / 2 + Math.sin(index * Math.PI / 2) * (crosshair.width / 2 - 1)
                y: crosshair.height / 2 - height / 2 - Math.cos(index * Math.PI / 2) * (crosshair.height / 2 - 1)
                color: crosshair.ink
            }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.top
            anchors.bottomMargin: 5
            width: Math.max(28, parent.width * .95)
            height: 4
            radius: 2
            color: "#a4302328"
            visible: feedback.cycling
            Rectangle {
                width: parent.width * feedback.readiness
                height: parent.height
                radius: 2
                color: feedback.weapon.color
            }
        }
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.bottom
            anchors.topMargin: 4
            width: parent.width * feedback.sealProgress
            height: 3
            visible: feedback.sealProgress > 0
            color: "#e4b3ff"
        }
    }
}

import QtQuick
import "../game" as Game
import "../game/Elements.js" as Elements
import "../game/Loadout.js" as Gear
import "../game/Pets.js" as Pets
import "../game/Encounters.js" as Encounters

Rectangle {
    id: portrait
    objectName: "galleryPortrait"
    required property var entry
    readonly property string kind: entry.glyph ? "weather" : entry.role ? "enemy" : entry.category === "Weapon" ? "weapon"
        : entry.category || !entry.form ? "ability" : "pet"
    property color tint: "#a8c4f0"
    property string enemyTier: ""
    property real ember: 0
    color: "#141b2b"
    border.color: entry.abyss ? Qt.lighter(Encounters.tierColors[enemyTier] || tint,1.47)
        : enemyTier ? Encounters.tierColors[enemyTier] : "#36435a"
    border.width: enemyTier === "Overlord" || entry.abyss ? 2 : 1
    radius: 5
    clip: true

    Loader {
        anchors.fill: parent
        anchors.margins: 3
        sourceComponent: portrait.kind === "enemy" ? enemyArt : portrait.kind === "weapon" ? weaponArt
            : portrait.kind === "pet" ? petArt : portrait.kind === "weather" ? weatherArt : abilityArt
    }
    Rectangle {
        anchors.fill: parent
        visible: portrait.enemyTier === "Nightmare" || portrait.enemyTier === "Overlord"
        gradient: Gradient {
            GradientStop { position:0; color: portrait.enemyTier === "Nightmare" ? "#ba0d071a" : "#63303a16" }
            GradientStop { position:.42; color: "transparent" }
            GradientStop { position:1; color: portrait.enemyTier === "Nightmare" ? "#a4110a26" : "#b4fc6327" }
        }
    }
    NumberAnimation on ember {
        from: 0; to: 1; duration: 2150; loops: Animation.Infinite
        running: portrait.visible && portrait.enemyTier === "Overlord"
    }
    Repeater {
        model: portrait.enemyTier === "Overlord" ? 9 : 0
        Rectangle {
            required property int index
            readonly property real age: (portrait.ember + index*.154)%1
            x: portrait.width * (.10 + (index*.381)% .79) + Math.sin(age*7+index)*3
            y: portrait.height * (.92-age*.64)
            width: 1.8 + index%3
            height: width*2.4
            radius: width*.5
            rotation: age*75
            color: index%3 ? "#ef9252" : "#ffd391"
            opacity: (1-age)*.8
        }
    }
    Component {
        id: weatherArt
        Text {
            text: portrait.entry.glyph
            color: portrait.tint
            font.pixelSize: Math.min(width,height)*.55
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
    Component {
        id: enemyArt
        Game.ProjectedWorld {
            motion: false
            portraitMode: true
            actors: portrait.entry.role ? [{
                id:1, type:portrait.entry.id, front:"front", lane:0, depth:(portrait.entry.ship ? 370 : 340) * portrait.entry.size,
                age:1.25, hp:1, fuse:portrait.entry.id === "seraphijus" ? 15 : 0, warp:0, flash:0, attack:4, barrier:portrait.entry.barrier || 0, roar:0, generation:0,
                turrets:portrait.entry.ship ? [
                    {hp:1,maximum:1,flash:0,tint:"#a6edff"}, {hp:1,maximum:1,flash:0,tint:"#dfb5ff"}, {hp:1,maximum:1,flash:0,tint:"#ffae69"}
                ] : null,
                elements:portrait.entry.id === "princoratus" ? { explosive:2 } : null
            }] : []
        }
    }
    Rectangle {
        anchors.fill: parent
        visible: portrait.enemyTier.length > 0
        color: "transparent"
        border.color: portrait.border.color
        border.width: portrait.border.width
        radius: portrait.radius
    }
    Component {
        id: weaponArt
        Item {
            Game.WeaponSprite {
                anchors.centerIn: parent
                width: parent.width * .86
                height: width * 150 / 336
                weapon: portrait.entry.category === "Weapon" ? portrait.entry : Gear.weapons.pistol
                catalogue: true
                shotLife: 0
                motion: false
            }
        }
    }
    Component {
        id: petArt
        Item {
            Game.ProjectedPet {
                anchors.centerIn: parent
                width: Math.min(parent.height * 1.21, parent.width * .76)
                height: width * .69
                helper: portrait.entry.form ? portrait.entry : Pets.spec("crow")
                flap: .12
            }
        }
    }
    Component {
        id: abilityArt
        Canvas {
            id: icon
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            Connections {
                target: portrait
                function onEntryChanged() { icon.requestPaint() }
                function onTintChanged() { icon.requestPaint() }
            }
            onPaint: {
                const ctx = getContext("2d")
                ctx.reset()
                ctx.clearRect(0, 0, width, height)
                const radius = Math.min(width, height) * .34
                ctx.translate(width / 2, height / 2)
                ctx.strokeStyle = portrait.tint
                ctx.fillStyle = portrait.tint
                ctx.lineWidth = 1.8
                const name = portrait.entry.id
                const seed = Array.from(name).reduce(function(score, character) { return score + character.charCodeAt(0) }, 0)
                const sides = portrait.entry.category === "Active" ? 3 + seed % 5 : 6
                ctx.beginPath()
                for (let i = 0; i <= sides; i += 1) {
                    const angle = 2 * Math.PI * i / sides - Math.PI * .5
                    ctx.lineTo(Math.cos(angle) * radius, Math.sin(angle) * radius)
                }
                ctx.stroke()
                const kind = portrait.entry.element || (name.includes("cryo") ? "freeze" : name.includes("grenade") || name === "frag" ? "explosive"
                    : name === "sunfall" ? "burn" : "")
                ctx.fillStyle = kind ? Elements.kinds[kind].color : portrait.tint
                for (let i = 0; i < 4 + seed % 3; i += 1) {
                    const angle = i * 2.4 + seed * .219
                    const distance = (.16 + (i % 3) * .16) * radius
                    ctx.beginPath()
                    ctx.arc(Math.cos(angle) * distance, Math.sin(angle) * distance, 2 + i % 3, 0, Math.PI * 2)
                    ctx.fill()
                }
            }
        }
    }
}

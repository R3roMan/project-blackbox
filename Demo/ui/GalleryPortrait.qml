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
    property bool engraved:false
    property color tint: "#a8c4f0"
    readonly property color itemTint: Gear.rarities[entry.rarity]?.color || tint
    property string enemyTier: ""
    property real ember: 0
    color: engraved ? "transparent" : "#141b2b"
    border.color: entry.abyss ? Qt.lighter(Encounters.tierColors[enemyTier] || tint,1.47)
        : enemyTier ? Encounters.tierColors[enemyTier] : "#36435a"
    border.width: engraved ? 0 : enemyTier === "Overlord" || entry.abyss ? 2 : 1
    radius: 5
    clip: true

    Loader {
        anchors.fill: parent
        anchors.margins: 3
        sourceComponent: portrait.entry.shopItem ? shopArt : portrait.kind === "enemy" ? enemyArt : portrait.kind === "weapon" ? weaponArt
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
            Game.PetPortrait3D {
                anchors.fill:parent
                visible:portrait.engraved && GraphicsInfo.api!==GraphicsInfo.Software
                helper:portrait.entry.form ? portrait.entry : Pets.spec("crow")
            }
            Game.ProjectedPet {
                anchors.centerIn: parent
                visible:!portrait.engraved || GraphicsInfo.api===GraphicsInfo.Software
                width: Math.min(parent.height * 1.21, parent.width * .76)
                height: width * .69
                helper: portrait.entry.form ? portrait.entry : Pets.spec("crow")
                flap: .12
            }
        }
    }
    Component {
        id:shopArt
        ShopItemGlyph { item:portrait.entry; tint:portrait.entry.color || portrait.itemTint; onPaper:portrait.engraved }
    }
    Component {
        id:abilityArt
        AbilityGlyph { entry:portrait.entry; tint:portrait.itemTint; onPaper:portrait.engraved }
    }
}

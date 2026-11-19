import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Rules.js" as Rules
import "Loadout.js" as Gear

Ui.ActionButton {
    id: card

    required property var offer
    property var run:null
    property int revision:0
    property bool animate: true
    property bool selected: false
    property bool compact: false
    property bool flask: false
    property string dragGroup: ""
    signal dragStarted()
    readonly property var tier: offer.rarity ? Rules.rarities[offer.rarity] : null
    readonly property color tint: tier ? tier.color : "#d9c6c3"
    readonly property bool legendary: offer.rarity === "legendary"
    property real gleam: 0

    objectName: "reward-" + offer.id
    implicitHeight: Math.max(flask ? (compact ? 140 : 190) : (compact ? 111 : 134), details.implicitHeight + topPadding + bottomPadding)
    topPadding: flask ? 33 : 8
    bottomPadding: flask ? 13 : 8
    hintEnabled: hovered
    hintDelay: 420
    entryChapter:offer.category==="Weapon" ? "weapons" : "abilities"
    entryId:["Weapon","Active","Passive"].includes(offer.category) ? offer.id : ""
    hintText:{
        revision
        return offer.title + "\n" + Gear.offerDetails(offer,run)
            + (offer.upgradeLevel ? "\nLv " + offer.upgradeLevel + " · " + offer.upgradeEffect : "")
            + (offer.hint ? "\n" + offer.hint : "")
    }
    text: offer.title
    Accessible.description: [tier ? tier.label : "", offer.category, offer.description].join(" ").trim()

    z: gearDrag.dragging ? 12 : 0

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 8
        width: 25
        height: 22
        radius: 4
        visible: card.dragGroup.length > 0
        color: "#42344a"
        border.color: card.tint
        Text {
            anchors.centerIn: parent
            text: "⠿"
            font.pixelSize: Ui.UiMetrics.text(15)
            color: "#fbecfa"
        }
        GearDrag {
            id: gearDrag
            objectName: "rewardGrip-" + card.offer.id
            anchors.fill: parent
            group: card.dragGroup
            title: card.text
            offerId: card.offer.id
            available: parent.visible
            onStarted: card.dragStarted()
        }
    }
    NumberAnimation on gleam {
        from: 0
        to: 1
        duration: 2300
        loops: Animation.Infinite
        running: card.visible && (card.legendary || card.flask) && card.animate
    }

    contentItem: ColumnLayout {
        id: details
        spacing: 4
        Text {
            Layout.fillWidth: true
            text: (card.tier ? card.tier.label + "  /  " : "") + card.offer.category
                + (card.offer.cooldown ? "  /  " + card.offer.cooldown + "s" : "")
            color: card.tint
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
            font.weight: Font.DemiBold
            elide: Text.ElideRight
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Ui.GalleryPortrait {
                Layout.preferredWidth: card.compact ? 37 : 47
                Layout.preferredHeight: card.compact ? 31 : 38
                entry: card.offer
                tint: card.tint
            }
            Text {
                Layout.fillWidth: true
                text: card.offer.title
                color: "#fff1e8"
                font.family: "Inter"
                font.pixelSize: card.compact ? 13 : 15
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
            }
        }
        Text {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: !!card.offer.upgradeLevel
            text: card.offer.upgradeLevel ? (card.offer.storedUpgrade ? "↑ INVENTORY · LV " : "↑ UPGRADE TO LV ") + card.offer.upgradeLevel + " / 3 · " + card.offer.upgradeEffect : ""
            color: "#a3edc4"
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(12)
            font.weight: Font.Bold
        }
        Text {
            Layout.fillWidth: true
            text: card.offer.description
            wrapMode: Text.WordWrap
            maximumLineCount: card.compact ? 4 : 6
            elide: Text.ElideRight
            color: "#e4d6e1"
            font.family: "Inter"
            font.pixelSize: Ui.UiMetrics.text(13)
        }
        Text {
            Layout.fillWidth: true
            visible: !!card.offer.hint
            text: card.offer.hint || ""
            color: card.tint
            font.family: "IBM Plex Mono"
            font.pixelSize: Ui.UiMetrics.text(10)
            elide: Text.ElideRight
        }
    }

    background: Rectangle {
        radius: card.flask ? 19 : 7
        clip: true
        color: card.down ? Qt.tint("#221927", Qt.rgba(card.tint.r, card.tint.g, card.tint.b, .17))
            : card.selected ? "#382a40" : card.hovered ? "#302435" : "#201a27"
        border.color: card.visualFocus || card.selected ? "#fff4dd" : card.flask ? "#77a897" : card.tint
        border.width: card.visualFocus || card.selected || card.legendary ? 2 : 1

        Rectangle {
            visible: card.flask
            anchors.fill: parent
            anchors.margins: 4
            radius: 14
            border.color: "#54766b"
            gradient: Gradient {
                GradientStop { position: 0; color: "#233a35" }
                GradientStop { position: .25; color: "#191f27" }
                GradientStop { position: .41; color: "#1a2e2b" }
                GradientStop { position: 1; color: card.hovered ? "#345739" : "#263e2a" }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 0
                width: parent.width * .47
                height: 22
                radius: 4
                color: "#35434b"
                border.color: card.tint
                Row {
                    anchors.centerIn: parent
                    spacing: 7
                    Repeater {
                        model: 5
                        Rectangle { width: 2; height: 13; color: "#617a76" }
                    }
                }
            }
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 7
                y: parent.height * .32
                height: 2
                radius: 1
                color: "#5f9a8090"
            }
            Repeater {
                model: card.flask ? 10 : 0
                Rectangle {
                    required property int index
                    readonly property real rise: (card.gleam + index * .163) % 1
                    x: 8 + (parent.width - 16) * ((index * .377) % 1)
                    y: parent.height * (.94 - .61 * rise)
                    width: 3 + index % 5 * 1.7
                    height: width
                    radius: width/2
                    opacity: .34 * Math.sin(rise * Math.PI)
                    color: "#8beba3"
                    border.color: "#c9facf"
                }
            }
        }
        Rectangle {
            x: 1
            y: 7
            width: 3
            height: parent.height - 14
            radius: 1.5
            color: card.tint
            visible: !card.flask
        }
        Rectangle {
            anchors.fill: parent
            visible: card.legendary
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0; color: "#57ffc257" }
                GradientStop { position: .54; color: "#00ffc257" }
                GradientStop { position: 1; color: "#4dffe87e" }
            }
        }
        Rectangle {
            visible: card.legendary && card.animate
            width: 52
            height: parent.height * 1.9
            color: "#39fff2a6"
            rotation: 24
            x: -105 + (parent.width + 175) * card.gleam
            y: -parent.height * .42
        }
        Repeater {
            model: card.legendary ? 5 : 0
            Rectangle {
                required property int index
                readonly property real drift: (card.gleam + index * .23) % 1
                x: parent.width - (index % 3) * 23 - 12 - drift * 12
                y: (1 - drift) * (parent.height - 8)
                width: index % 2 + 2
                height: width
                radius: width / 2
                color: "#fff5af"
                opacity: Math.sin(drift * Math.PI) * .82
            }
        }
    }
}

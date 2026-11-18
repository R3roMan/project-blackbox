import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear
import "Pets.js" as Pets

ColumnLayout {
    id: shop
    objectName: "bossShop"
    required property var run
    required property int revision
    property bool compact: false
    property bool nativeScene: false
    property bool motion: true
    signal purchaseRequested(string offerId, int slot)

    readonly property int balance: { revision; return run.gold }
    readonly property var cards: { revision; return Gear.shopCards(run).slice() }
    readonly property int edition: { revision; return run.shopEdition }
    property string selectedId: ""
    onEditionChanged: {
        selectedId = ""
        selectedSlot = -1
    }
    property int selectedSlot: -1
    readonly property var selected: cards.find(function(item) { return item.id === selectedId })
    readonly property var premium: selected && selected.action === "gear" ? Gear.catalogs[selected.group][selected.gearId] : null
    readonly property int slotForPremium: { revision; return premium ? Gear.defaultSlot(run, premium) : -1 }
    readonly property bool pickSlot: !!premium && slotForPremium === -1 && !selected.sold
    readonly property bool storing: selectedSlot === Gear.inventoryDestination || slotForPremium === Gear.inventoryDestination
    readonly property bool canStash: { revision; return !!premium && !Gear.ownedItem(run, selected.group, premium.id) && Gear.canStore(run) }
    readonly property color rarityTone: selected && selected.rarity === "unique" ? Pets.uniqueColor
        : selected && selected.rarity ? Gear.rarities[selected.rarity].color : "#a7c5ee"
    spacing: compact ? 7 : 10

    function displayItem(offer) {
        if (offer.gearId)
            return Gear.catalogs[offer.group][offer.gearId]
        if (offer.action === "pet" && run.pet)
            return Pets.spec(run.pet.id)
        if (offer.action === "upgrade" && run.slots[offer.group][offer.index].item)
            return Gear.catalogs[offer.group][run.slots[offer.group][offer.index].item.id]
        return offer
    }

    ShopBench {
        Layout.fillWidth: true
        Layout.preferredHeight: shop.compact ? 107 : 149
        nativeScene: shop.nativeScene
        motion: shop.motion
        cards: shop.cards
        selectedId: shop.selectedId
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: shop.compact ? 8 : 12
        GridLayout {
            Layout.fillWidth: true
            Layout.preferredWidth: 375
            Layout.alignment: Qt.AlignTop
            columns: 2
            uniformCellWidths: true
            rowSpacing: 5
            columnSpacing: 5

            Text {
                Layout.columnSpan: 2
                Layout.fillWidth: true
                text: {
                    shop.revision
                    return shop.cards.filter(function(card) { return !card.sold }).length + " / " + shop.run.shopCapacity
                        + " listings left   ·   Repeat luck " + (Gear.repeatChance(shop.run.repeatRank)*100).toFixed(1) + "%"
                }
                font.family: "IBM Plex Mono"
                font.pixelSize: 11
                color: "#b8a997"
            }
            Repeater {
                model: shop.cards
                delegate: Ui.ActionButton {
                    id: listing
                    required property var modelData
                    objectName: "shop-" + modelData.id
                    Layout.fillWidth: true
                    implicitHeight: shop.compact ? 36 : 42
                    leftPadding: 6
                    rightPadding: 6
                    text: modelData.title
                    primary: shop.selectedId === modelData.id
                    accent: "#a8bded"
                    Accessible.description: modelData.description
                    hintEnabled: hovered
                    hintDelay: 420
                    readonly property var shown: shop.displayItem(modelData)
                    hintText: modelData.title + "\n" + (modelData.group && Gear.catalogs[modelData.group] && Gear.catalogs[modelData.group][shown.id] ? Gear.itemDetails(shop.run,modelData.group,{id:shown.id,level:modelData.level || 0}) : modelData.description) +
                        (modelData.sold ? "\nPurchased" : modelData.paid ? "\nPaid · choose a destination" : "\n" + modelData.cost + " gold")
                    onClicked: {
                        shop.selectedId = modelData.id
                        shop.selectedSlot = -1
                    }

                    contentItem: RowLayout {
                        Ui.GalleryPortrait {
                            Layout.preferredWidth: shop.compact ? 24 : 29
                            Layout.preferredHeight: 23
                            entry: listing.shown
                            tint: listing.modelData.rarity === "unique" ? Pets.uniqueColor :
                                listing.modelData.rarity ? Gear.rarities[listing.modelData.rarity].color : "#a9bedb"
                        }
                        Text {
                            Layout.fillWidth: true
                            text: listing.text
                            color: listing.primary ? "#161d2e" : listing.modelData.sold ? "#a1adbf" : "#edf0fc"
                            font.family: "Inter"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                        }
                        Text {
                            text: listing.modelData.sold ? "Sold" : listing.modelData.paid ? "Claim" : listing.modelData.cost
                            color: listing.primary ? "#29364d" : listing.modelData.sold ? "#a1adbf" : "#ffdf93"
                            font.family: "IBM Plex Mono"
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 380
            Layout.minimumHeight: info.implicitHeight + 22
            radius: 6
            color: "#202738"
            border.color: "#425370"
            Ui.PanelPlating { anchors.fill: parent; tone: "#657fa0"; blood: .31 }

            ColumnLayout {
                id: info
                anchors.fill: parent
                anchors.margins: 11
                spacing: 7
                Text {
                    objectName: "shopBalance"
                    text: shop.balance + " GOLD"
                    color: "#ffe094"
                    font.family: "IBM Plex Mono"
                    font.weight: Font.Bold
                    font.pixelSize: 13
                }
                Text {
                    Layout.fillWidth: true
                    text: shop.selected ? shop.selected.title : "Select a listing"
                    color: shop.rarityTone
                    font.family: "Inter"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                    GearDrag {
                        anchors.fill: parent
                        group: shop.premium ? shop.selected.group : ""
                        offerId: shop.selectedId
                        title: shop.premium ? shop.premium.title : ""
                        available: shop.pickSlot
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: shop.selected ? Gear.kitDescription(shop.selected.group,shop.displayItem(shop.selected).id,shop.selected.description) : ""
                    wrapMode: Text.WordWrap
                    color: "#d5e0f0"
                    font.family: "Inter"
                    font.pixelSize: 12
                }
                Text {
                    Layout.fillWidth: true
                    visible: !!shop.premium
                    text: {
                        shop.revision
                        if (!shop.premium || shop.selected.sold)
                            return ""
                        if (shop.storing)
                            return "Sent straight to your inventory · no equipped item is replaced."
                        const destination = shop.pickSlot ? shop.selectedSlot : shop.slotForPremium
                        const existing = shop.run.slots[shop.selected.group][destination]
                        if (!existing)
                            return "Choose a slot."
                        if (!existing.item)
                            return "Equips in empty slot " + (destination + 1) + "."
                        if (existing.item.id === shop.premium.id)
                            return "Upgrade to Lv " + (existing.item.level + 1) + " · " + Gear.upgradeText(shop.premium, existing.item.level + 1)
                        return "Replaces " + Gear.catalogs[shop.selected.group][existing.item.id].title
                            + " in slot " + (destination + 1) + (Gear.canStore(shop.run) ? ". The old item moves to inventory." : ". Inventory full: the old item is discarded.")
                    }
                    wrapMode: Text.WordWrap
                    color: "#aebed8"
                    font.family: "Inter"
                    font.pixelSize: 11
                }
                LoadoutGrid {
                    Layout.fillWidth: true
                    visible: shop.pickSlot
                    run: shop.run
                    revision: shop.revision
                    compact: true
                    groups: shop.pickSlot ? [shop.selected.group] : []
                    offerId: shop.selectedId
                    selectedGroup: shop.pickSlot ? shop.selected.group : ""
                    selectedIndex: shop.selectedSlot
                    onPlaced: function(offerId, slot) { shop.selectedSlot = slot }
                }
                RowLayout {
                    Ui.ActionButton {
                        visible: shop.canStash && !shop.selected.sold
                        text: shop.selectedSlot === Gear.inventoryDestination ? "Use slot" : "Store instead"
                        onClicked: shop.selectedSlot = shop.selectedSlot === Gear.inventoryDestination ? -1 : Gear.inventoryDestination
                    }
                    Ui.ActionButton {
                        objectName: "buyShopOffer"
                        enabled: !!shop.selected && !shop.selected.sold && shop.balance >= shop.selected.cost
                            && (!shop.pickSlot || shop.selectedSlot >= 0 || shop.storing)
                        primary: true
                        accent: "#a8bded"
                        text: {
                            if (!shop.selected) return "Buy"
                            if (shop.selected.sold) return "Purchased"
                            if (shop.selected.paid) return "Claim item"
                            return (shop.selected.action === "mystery" ? "Unwrap · " : "Buy · ") + shop.selected.cost + " gold"
                        }
                        onClicked: {
                            const destination = shop.storing ? Gear.inventoryDestination : shop.pickSlot ? shop.selectedSlot : shop.slotForPremium
                            shop.purchaseRequested(shop.selected.id, destination)
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}

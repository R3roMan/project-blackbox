import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear
import "Pets.js" as Pets
import "Selection.js" as Draw

ColumnLayout {
    id: shop
    objectName: "bossShop"
    required property var run
    required property int revision
    property bool compact: false
    property bool nativeScene: false
    property bool motion: true
    readonly property bool stacked: width < 590
    signal entryRequested(string chapter, string id)
    signal purchaseRequested(string offerId, int slot, string confirmed)
    signal freezeRequested(string offerId)
    signal refundRequested(string group,string id)
    readonly property var refundable:{revision;return Gear.refundableAbilities(run)}
    property bool refundsOpen:false

    readonly property real balance: { revision; return Gear.availableGold(run) }
    readonly property var cards: { revision; return Gear.shopCards(run) }
    readonly property var expansion:{revision;return Gear.counterOffer(run)}
    readonly property int edition: { revision; return run.shopEdition }
    property string selectedId: ""
    property string pendingReplacement: ""
    onSelectedIdChanged:pendingReplacement=""
    onEditionChanged: {
        selectedId = ""
        selectedSlot = -1
    }
    property int selectedSlot: -1
    readonly property var selected: cards.find(function(item) { return item.id === selectedId })
        || cards.find(function(item) { return !item.sold }) || cards[0]
    readonly property var premium: selected && selected.action === "gear" ? Gear.catalogs[selected.group][selected.gearId] : null
    readonly property int slotForPremium: { revision; return premium ? Gear.defaultSlot(run, premium) : -1 }
    readonly property bool pickSlot: !!premium && slotForPremium === -1 && !selected.sold
    readonly property bool storing: selectedSlot === Gear.inventoryDestination || slotForPremium === Gear.inventoryDestination
    readonly property bool canStash: { revision; return !!premium && !Gear.ownedItem(run, selected.group, premium.id) && Gear.canStore(run) }
    readonly property var replacing:{revision;return Gear.replacement(run,selected)}
    readonly property string replacingKey:Gear.replacementKey(replacing)
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
        return Object.assign({shopItem:true},offer)
    }

    function compared(offer) {
        if (!offer || offer.group!=="weapon" || !offer.gearId) return []
        const owned=Gear.ownedItem(run,"weapon",offer.gearId)
        const level=offer.action==="upgrade" ? offer.level : owned ? Math.min(3,owned.level+1) : 0
        return Gear.weaponComparison(run,Gear.current(run),{id:offer.gearId,level:level})
    }

    function details(offer) {
        if (!offer) return ""
        if (offer.action==="power" || offer.action==="power-upgrade") {
            const slot=run.slots[offer.group][offer.index]
            if (!slot) return offer.description || ""
            const spec=offer.powerId || slot.power
            const level=offer.action==="power" ? 0 : (offer.level || slot.powerLevel+1)
            const effect=Gear.slotPower(offer.group,{power:spec,powerLevel:level})
            const applies=Gear.socketEffect(run,offer.group,{item:slot.item,power:spec,powerLevel:level}).id
            const previous=Gear.replacement(run,offer)
            const gear=slot.item ? Gear.catalogs[offer.group][slot.item.id] : null
            return Gear.groupLabels[offer.group]+" slot "+(offer.index+1)+" · Lv "+level+"\n"+effect.description+"\n"
                +(applies ? "Works with "+gear.title+"." : gear ? "Inactive with "+gear.title+" in the current build." : "Equip compatible gear to activate it.")
                +(previous.id ? "\nReplaces "+previous.title+" · Lv "+previous.level+"." : "")
        }
        const shown=displayItem(offer)
        return Gear.catalogs[offer.group]?.[shown.id] ? Gear.itemDetails(run,offer.group,{id:shown.id,level:offer.level || 0})
            : (offer.description || "")
    }

    function purchase(confirmed) {
        if (!selected || selected.sold) return
        const destination=storing ? Gear.inventoryDestination : pickSlot ? selectedSlot : slotForPremium
        if (replacingKey && confirmed!==replacingKey) {
            pendingReplacement=replacingKey
            return
        }
        purchaseRequested(selected.id,destination,confirmed)
        pendingReplacement=""
    }

    ShopBench {
        Layout.fillWidth: true
        Layout.preferredHeight:shop.compact ? 106 : 165
        nativeScene: shop.nativeScene
        motion: shop.motion
        cards: shop.cards
        selectedId:shop.selected?.id || ""
    }

    RowLayout {
        Layout.fillWidth:true
        spacing:8
        Text {
            Layout.fillWidth:true
            text:{ shop.revision;return shop.run.shopCapacity+" / 8 listings open  ·  Stock quality "+(shop.run.shopQuality || 0)+"/3" }
            font.family:"Inter"
            font.bold:true
            font.pixelSize:Ui.UiMetrics.text(14)
            color:"#f9dec0"
            wrapMode:Text.WordWrap
        }
        Ui.ActionButton {
            accent:"#d0a46e"
            visible:!!shop.expansion
            objectName:"expandShopCounter"
            text:shop.expansion ? shop.expansion.title+" · "+shop.expansion.cost+" gold" : ""
            entryChapter:"shop"
            entryId:"expand-counter"
            hintText:shop.expansion ? shop.expansion.title+"\n"+shop.expansion.description : ""
            enabled:!!shop.expansion && shop.balance>=shop.expansion.cost
            onEntryRequested:function(chapter,id) {shop.entryRequested(chapter,id)}
            onClicked:shop.purchaseRequested("expand-counter",-1,"")
        }
        Ui.ActionButton {
            accent:"#d0a46e"
            visible:shop.refundable.length>0
            objectName:"showRefunds"
            text:"Refund ranks"
            primary:shop.refundsOpen
            onClicked:shop.refundsOpen=!shop.refundsOpen
        }
        Ui.ActionButton {
            objectName:"shopLedger"
            text:shop.compact ? "Ledger" : "Shop ledger"
            onClicked:shop.entryRequested("shop","counter")
        }
    }
    RowLayout {
        Layout.fillWidth:true
        spacing:5
        Repeater {
            model:8
            Rectangle {
                required property int index
                readonly property int openCount:{shop.revision;return shop.run.shopCapacity}
                readonly property bool unlocked:index<openCount
                Layout.fillWidth:true
                implicitHeight:5
                radius:2
                color:unlocked ? "#d9a36d" : index===openCount ? "#566d87" : "#352a36"
                Accessible.name:(unlocked ? "Open listing " : "Locked listing ")+(index+1)
            }
        }
    }

    Flow {
        Layout.fillWidth:true
        visible:shop.refundsOpen && shop.refundable.length>0
        spacing:5
        Repeater {
            model:shop.refundable
            Ui.ActionButton {
                required property var modelData
                text:modelData.title+" · +"+modelData.amount+" gold"
                hintText:"Refund the last paid rank."
                onClicked:shop.refundRequested(modelData.group,modelData.id)
                TapHandler {
                    acceptedButtons:Qt.RightButton
                    onTapped:shop.refundRequested(parent.modelData.group,parent.modelData.id)
                }
            }
        }
    }
    GridLayout {
        Layout.fillWidth: true
        columns:shop.stacked ? 1 : 2
        rowSpacing:8
        columnSpacing:12
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
                font.pixelSize: Ui.UiMetrics.text(12)
                color: "#b8a997"
            }
            Repeater {
                model: shop.cards
                delegate: Ui.ActionButton {
                    id: listing
                    required property var modelData
                    objectName: "shop-" + modelData.id
                    Layout.fillWidth: true
                    implicitHeight:Math.max(shop.compact ? 45 : 57,Ui.UiMetrics.text(28)+11)
                    opacity:modelData.sold && !primary ? .73 : 1
                    leftPadding: 6
                    rightPadding: 6
                    text: modelData.title
                    primary:shop.selected?.id === modelData.id
                    accent: modelData.color || "#a8bded"
                    Accessible.description: {shop.revision;return shop.details(modelData)}
                    hintEnabled: hovered
                    hintDelay: 420
                    readonly property var shown: shop.displayItem(modelData)
                    readonly property int refund:{shop.revision;return Gear.refundableRank(shop.run,modelData.group,modelData.gearId)}
                    TapHandler {
                        acceptedButtons:Qt.RightButton
                        enabled:listing.refund>0
                        onTapped:shop.refundRequested(listing.modelData.group,listing.modelData.gearId)
                    }
                    entryChapter:modelData.action==="gear" ? (modelData.group==="weapon" ? "weapons" : "abilities") : "shop"
                    entryId:modelData.action==="gear" ? modelData.gearId : Gear.shopEntryId(modelData)
                    onEntryRequested:function(chapter,id) { shop.entryRequested(chapter,id) }
                    hintStats:{shop.revision;return shop.compared(modelData)}
                    hintText: modelData.title + "\n" + shop.details(modelData) +
                        (modelData.sold ? "\nPurchased" : modelData.paid ? "\nPaid · choose a destination" : "\n" + modelData.cost + " gold")
                        +(refund ? "\nRight-click to refund one rank · "+refund+" gold" : "")
                    onClicked: {
                        shop.selectedId = modelData.id
                        shop.selectedSlot = -1
                    }

                    background:Rectangle {
                        radius:7
                        color:listing.primary ? "#dfaa79" : listing.hovered ? "#392633" : "#e9271e2b"
                        border.color:listing.visualFocus ? "#ffe5d3" : listing.primary ? "#f4c38e" : "#785466"
                        Rectangle {
                            width:3;height:parent.height-10;x:4;y:5;radius:1
                            color:listing.primary ? "#6e3b48" : listing.modelData.color || "#b09490"
                            opacity:listing.modelData.sold ? .36 : .9
                        }
                    }
                    contentItem: RowLayout {
                        anchors.leftMargin:4
                        Ui.GalleryPortrait {
                            Layout.preferredWidth:shop.compact ? 29 : 37
                            Layout.preferredHeight:shop.compact ? 27 : 33
                            entry: listing.shown
                            tint: listing.modelData.rarity === "unique" ? Pets.uniqueColor :
                                listing.modelData.rarity ? Gear.rarities[listing.modelData.rarity].color : "#a9bedb"
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing:1
                            Text {
                                Layout.fillWidth:true
                                text:listing.text
                                color:listing.primary ? "#271922" : listing.modelData.sold ? "#ac9a9c" : "#f7e9dc"
                                font.family:"Inter"
                                font.bold:true
                                font.pixelSize:Ui.UiMetrics.text(13)
                                elide:Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth:true
                                text:Gear.shopCategory(listing.modelData.action)
                                color:listing.primary ? "#3a3141" : "#d5af91"
                                font.family:"Inter"
                                font.pixelSize:Ui.UiMetrics.text(10)
                                elide:Text.ElideRight
                            }
                        }
                        Text {
                            text: {shop.revision;return listing.modelData.sold ? "Sold" : listing.modelData.paid ? "Claim"
                                : (Draw.isFrozen(shop.run,listing.modelData) ? "❄ " : "")+listing.modelData.cost}
                            color: listing.primary ? "#29364d" : listing.modelData.sold ? "#a1adbf" : "#ffdf93"
                            font.family: "IBM Plex Mono"
                            font.pixelSize: Ui.UiMetrics.text(13)
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
            color:"#201823"
            gradient:Gradient {
                GradientStop {position:0;color:"#352632"}
                GradientStop {position:1;color:"#211924"}
            }
            border.color:"#946879"
            Ui.PanelPlating {anchors.fill:parent;tone:"#b49078";blood:.35}

            ColumnLayout {
                id: info
                anchors.fill: parent
                anchors.margins: 11
                spacing: 7
                Text {
                    objectName: "shopBalance"
                    text: (Number.isFinite(shop.balance) ? shop.balance : "∞") + " GOLD"
                    color: "#ffe094"
                    font.family: "IBM Plex Mono"
                    font.weight: Font.Bold
                    font.pixelSize: Ui.UiMetrics.text(14)
                }
                RowLayout {
                    Layout.fillWidth:true
                    visible:!!shop.selected
                    Ui.GalleryPortrait {
                        Layout.preferredWidth:shop.compact ? 49 : 70
                        Layout.preferredHeight:shop.compact ? 35 : 48
                        entry:shop.selected ? shop.displayItem(shop.selected) : {shopItem:true,id:"counter"}
                        tint:shop.rarityTone
                    }
                    Text {
                        Layout.fillWidth:true
                        text:shop.selected ? Gear.shopCategory(shop.selected.action) : ""
                        color:"#dfc1b7"
                        font.family:"IBM Plex Mono"
                        font.pixelSize:Ui.UiMetrics.text(12)
                        wrapMode:Text.WordWrap
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: shop.pendingReplacement ? "Replace "+shop.replacing.title+"?" : shop.selected ? shop.selected.title : "Select a listing"
                    color: shop.rarityTone
                    font.family: "Inter"
                    font.pixelSize: Ui.UiMetrics.text(18)
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                    GearDrag {
                        anchors.fill: parent
                        group: shop.premium ? shop.selected.group : ""
                        offerId:shop.selected?.id || ""
                        title: shop.premium ? shop.premium.title : ""
                        available: shop.pickSlot
                    }
                }
                Flow {
                    Layout.fillWidth:true
                    spacing:5
                    visible:!!shop.selected && !shop.pendingReplacement
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
                        accent:"#ecb587"
                        text: {
                            if (!shop.selected) return "Buy"
                            if (shop.selected.sold) return "Purchased"
                            if (shop.selected.paid) return "Claim item"
                            return (shop.selected.action === "mystery" ? "Unwrap · " : "Buy · ") + shop.selected.cost + " gold"
                        }
                        onClicked: shop.purchase("")
                    }
                    Ui.ActionButton {
                        objectName:"freezeShopOffer"
                        visible:{shop.revision;return !!shop.selected && Draw.canFreeze(shop.run)}
                        enabled:{shop.revision;return !!Draw.freezable(shop.run,"shop",shop.selected)}
                        readonly property bool frozen:{shop.revision;return Draw.isFrozen(shop.run,shop.selected)}
                        primary:frozen
                        accent:"#a5d6f0"
                        text:frozen ? "❄ Frozen" : "Freeze"
                        hintText:"Save this listing for the next boss shop."
                        onClicked:shop.freezeRequested(shop.selected.id)
                    }
                }
                Flow {
                    visible:shop.pendingReplacement.length>0
                    Layout.fillWidth:true
                    spacing:6
                    Ui.ActionButton {objectName:"cancelSlotReplacement";text:"Keep current"; onClicked:shop.pendingReplacement=""}
                    Ui.ActionButton {
                        objectName:"confirmSlotReplacement"
                        text:shop.selected ? "Replace · "+shop.selected.cost+" gold" : "Replace"
                        primary:true
                        enabled:!!shop.selected && shop.balance>=shop.selected.cost && shop.pendingReplacement===shop.replacingKey
                        onClicked:shop.purchase(shop.pendingReplacement)
                    }
                }
                LoadoutGrid {
                    Layout.fillWidth: true
                    visible: shop.pickSlot
                    run: shop.run
                    revision: shop.revision
                    compact: true
                    groups: shop.pickSlot ? [shop.selected.group] : []
                    offerId:shop.selected?.id || ""
                    selectedGroup: shop.pickSlot ? shop.selected.group : ""
                    selectedIndex: shop.selectedSlot
                    onEntryRequested:function(chapter,id) { shop.entryRequested(chapter,id) }
                    onPlaced: function(offerId, slot) { shop.selectedSlot = slot }
                }
                Text {
                    Layout.fillWidth: true
                    visible: !!shop.premium && !shop.selected.sold
                    text: {
                        shop.revision
                        if (!shop.premium || shop.selected.sold)
                            return ""
                        if (shop.storing)
                            return "Destination: inventory."
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
                    font.pixelSize: Ui.UiMetrics.text(12)
                }
                Text {
                    Layout.fillWidth: true
                    visible: !!shop.selected
                    text: {shop.revision;return shop.selected ? shop.details(shop.selected) : ""}
                    wrapMode: Text.WordWrap
                    color: "#d5e0f0"
                    font.family: "Inter"
                    font.pixelSize: Ui.UiMetrics.text(13)
                }
                Ui.StatComparison {
                    Layout.fillWidth:true
                    rows:{shop.revision;return shop.compared(shop.selected)}
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}

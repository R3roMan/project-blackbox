pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Meta.js" as Meta

FocusScope {
    id: shop
    objectName: "witchShop"
    focus:true
    required property var ledger
    property bool inspecting:false
    property var sandbox:null
    readonly property var shown:inspecting ? sandbox : ledger
    signal practicePurchase()
    property bool vaultOpened: false
    property bool motion: true
    signal backRequested()
    signal refundRequested(string id)
    signal purchaseRequested(string id)
    signal cardRequested(string id)
    property int shelf: 0
    property var selection: Meta.vows[0]
    property var preview: null
    readonly property var speaking: shelf===3 ? Meta.reading : preview || selection
    readonly property bool tight: width < 925 || height < 645
    readonly property real panelScale: tight ? 1 : Math.max(1,Math.min(2,width/1450,height/820))
    readonly property var stock: shelf===0 ? Meta.vows : shelf===1 ? Meta.parcels : []
    readonly property bool eligible: !!selection && Meta.canBuy(shown,selection,inspecting)

    function buy(id) {
        if (!inspecting) {purchaseRequested(id);return}
        const data=Meta.read(JSON.stringify(sandbox))
        if (Meta.buy(data,id,null,true)) {
            sandbox=data
            practicePurchase()
        }
    }

    function refund(item) {
        if (!item?.cap || !Meta.level(shown,item.id)) return
        selection=item
        if (!inspecting) {refundRequested(item.id);return}
        const data=Meta.read(JSON.stringify(sandbox))
        if (Meta.refund(data,item.id)) {
            sandbox=data
            practicePurchase()
        }
    }

    function switchShelf(index) {
        shelf=index
        preview=null
        selection=stock[0] || null
        listings.positionViewAtBeginning()
    }

    Image {
        anchors.fill: parent
        source: "../art/witch-vault-tarot.webp"
        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: shop.tight ? Image.AlignHCenter : Image.AlignLeft
        asynchronous: true
        sourceSize.width: Math.min(2048, width*Screen.devicePixelRatio)
    }
    Rectangle {
        anchors.fill:parent
        gradient:Gradient {
            orientation:Gradient.Horizontal
            GradientStop {position:0;color:"#18101519"}
            GradientStop {position:.42;color:"#58130e21"}
            GradientStop {position:1;color:"#ef160e23"}
        }
    }

    ActionButton {
        objectName:"leaveWitchShop"
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.margins:shop.tight ? 12 : 26*shop.panelScale
        scale:shop.panelScale
        transformOrigin:Item.TopLeft
        text:"← Shrine"
        onClicked:shop.backRequested()
    }
    Keys.onEscapePressed: shop.backRequested()

    ShrineFrame {
        id: dialogue
        width: Math.max(140,Math.min(440,ledgerPanel.x-34))
        anchors.bottom: parent.bottom
        anchors.left:parent.left
        anchors.leftMargin:shop.tight ? 12 : 28*shop.panelScale
        anchors.bottomMargin:shop.tight ? 12 : 24*shop.panelScale
        scale:shop.panelScale
        transformOrigin:Item.BottomLeft
        implicitHeight:voice.implicitHeight+24
        fill:InterfaceTheme.current.surface
        Column {
            id:voice
            anchors.left:parent.left
            anchors.right:parent.right
            anchors.top:parent.top
            anchors.margins:12
            spacing:5
            Text {
                text:"THE WITCH"
                font.family:"IBM Plex Mono"
                font.letterSpacing:2
                font.pixelSize:UiMetrics.text(11)
                color:"#e1b784"
            }
            Text {
                objectName:"witchDialogue"
                width:parent.width
                text:"“"+(shop.speaking?.line || (shop.vaultOpened
                    ? "You did bring down the hundredth. So patient. The things behind this door take longer to wake."
                    : "The lock knows the hundredth Overlord. It doesn't know you. Yet."))+"”"
                font.family:"Cormorant Garamond"
                font.italic:true
                font.bold:true
                font.pixelSize:UiMetrics.text(shop.tight ? 16 : 24)
                wrapMode:Text.WordWrap
                color:"#fff0e9"
            }
        }
    }

    ShrineFrame {
        id: ledgerPanel
        width: shop.tight ? Math.min(parent.width-175,parent.width*.70) : Math.min(800,parent.width*.55/shop.panelScale)
        height: shop.tight ? parent.height-22 : Math.min(780,parent.height/shop.panelScale-46)
        scale:shop.panelScale
        transformOrigin:Item.Right
        anchors.right:parent.right
        anchors.rightMargin:shop.tight ? 11 : 23*shop.panelScale
        anchors.verticalCenter:parent.verticalCenter
        decorated:true
        blood:.72

        ColumnLayout {
            anchors.fill:parent
            anchors.margins:shop.tight ? 12 : 24
            spacing:shop.tight ? 7 : 12
            RowLayout {
                Layout.fillWidth:true
                Text {
                    Layout.fillWidth:true
                    text:"The Witch’s Vault"
                    font.family:"Cormorant Garamond"
                    font.bold:true
                    color:"#ffe3ce"
                    font.pixelSize:UiMetrics.text(shop.tight ? 25 : 40)
                    wrapMode:Text.WordWrap
                }
                Text {
                    objectName:"gemsBalance"
                    text:"◆ "+(shop.inspecting ? "∞" : shop.shown.gems)+"\nDark gems"
                    color:"#e4b5fc"
                    font.family:"Inter"
                    font.bold:true
                    font.pixelSize:UiMetrics.text(shop.tight ? 12 : 15)
                    horizontalAlignment:Text.AlignRight
                }
            }
            Flow {
                Layout.fillWidth:true
                spacing:5
                Repeater {
                    model:["Permanent","Temporary","Sealed shelf","Tarot"]
                    ActionButton {
                        required property int index
                        required property string modelData
                        objectName:"witchShelf"+index
                        text:modelData
                        primary:shop.shelf===index
                        accent:"#c396df"
                        onClicked:shop.switchShelf(index)
                    }
                }
            }
            ActionButton {
                objectName:"witchDebug"
                text:shop.inspecting ? "Debug vault · On" : "Debug vault"
                primary:shop.inspecting
                accent:"#c396df"
                hintText:"Inspect maximum ranks and try purchases with unlimited practice gems."
                onClicked:{
                    if (!shop.inspecting) shop.sandbox=Meta.practiceLedger()
                    shop.inspecting=!shop.inspecting
                }
            }
            ListView {
                id:listings
                Layout.fillWidth:true
                Layout.fillHeight:true
                clip:true
                spacing:5
                model:shop.stock
                visible:shop.shelf<2
                boundsBehavior:Flickable.StopAtBounds
                ScrollBar.vertical:ScrollBar {policy:ScrollBar.AsNeeded}
                delegate:ActionButton {
                    id:listing
                    required property var modelData
                    width:ListView.view.width-9
                    implicitHeight:Math.max(shop.tight ? 39 : 54,UiMetrics.text(25)+10)
                    objectName:"witchItem-"+modelData.id
                    readonly property bool queued:!!shop.shown.pending[modelData.id]
                    readonly property int rank:Meta.level(shop.shown,modelData.id)
                    primary:shop.selection?.id===modelData.id
                    accent:modelData.rarity==="legendary" ? "#f8d382" : "#c399e5"
                    text:modelData.title
                    Accessible.description:modelData.description+" "+modelData.line
                    onHoveredChanged: {
                        if (hovered) shop.preview=modelData
                        else if (shop.preview?.id===modelData.id) shop.preview=null
                    }
                    onActiveFocusChanged:if (activeFocus) shop.preview=modelData
                    onClicked:shop.selection=modelData
                    TapHandler {
                        acceptedButtons:Qt.RightButton
                        enabled:listing.modelData.cap>0 && listing.rank>0
                        onTapped:shop.refund(listing.modelData)
                    }
                    contentItem: RowLayout {
                        Text {text:listing.modelData.glyph;color:listing.primary ? "#38204a" : listing.accent;font.pixelSize:UiMetrics.text(18);Layout.leftMargin:4}
                        Text {
                            Layout.fillWidth:true
                            text:listing.modelData.title
                            font.family:"Inter"
                            font.bold:true
                            font.pixelSize:UiMetrics.text(13)
                            color:listing.primary ? "#22142e" : "#f9e6ee"
                            elide:Text.ElideRight
                        }
                        SaleSticker {
                            sale:Meta.discount(shop.shown,listing.modelData)
                            visible:sale>0 && Meta.inStock(shop.shown,listing.modelData)
                        }
                        Text {
                            text:listing.modelData.cap ? listing.rank+" / "+listing.modelData.cap
                                : listing.queued ? "Reserved" : "◆ "+Meta.price(shop.shown,listing.modelData)
                            font.family:"IBM Plex Mono"
                            font.pixelSize:UiMetrics.text(12)
                            color:listing.primary ? "#4f325c" : "#d3adc9"
                            Layout.rightMargin:4
                        }
                    }
                }
            }
            TarotReading {
                visible:shop.shelf===3
                Layout.fillWidth:true
                Layout.fillHeight:true
                ledger:shop.shown
                unlimited:shop.inspecting
                motion:shop.motion
                onBuyRequested:shop.buy(Meta.reading.id)
                onTurnRequested:function(id) {
                    if (!shop.inspecting) {shop.cardRequested(id);return}
                    const data=Meta.read(JSON.stringify(shop.sandbox))
                    if (Meta.turnCard(data,id)) shop.sandbox=data
                }
            }
            Item {
                visible:shop.shelf===2
                Layout.fillWidth:true
                Layout.fillHeight:true
                Column {
                    anchors.centerIn:parent
                    width:parent.width-20
                    spacing:9
                    Text {width:parent.width;horizontalAlignment:Text.AlignHCenter;text:"⟡";font.pixelSize:54;color:"#b995c1"}
                    Text {
                        objectName:"sealedWitchShelf"
                        width:parent.width
                        text:(shop.vaultOpened || shop.inspecting) ? "Coming soon" : "Sealed by the hundredth Overlord"
                        wrapMode:Text.WordWrap
                        horizontalAlignment:Text.AlignHCenter
                        font.family:"Inter"
                        font.bold:true
                        font.pixelSize:UiMetrics.text(17)
                        color:"#e6cff3"
                    }
                    Text {
                        width:parent.width
                        text:(shop.vaultOpened || shop.inspecting) ? "The deeper bargains are still being prepared." : "Defeat the Wave 100 boss in a regular run."
                        wrapMode:Text.WordWrap
                        horizontalAlignment:Text.AlignHCenter
                        font.family:"Inter"
                        font.pixelSize:UiMetrics.text(13)
                        color:"#cfb6cf"
                    }
                }
            }
            Rectangle {
                Layout.fillWidth:true
                Layout.preferredHeight:details.implicitHeight+20
                visible:!!shop.selection
                color:"#251930"
                radius:7
                border.color:"#684b72"
                ColumnLayout {
                    id:details
                    anchors.fill:parent
                    anchors.margins:10
                    Text {
                        Layout.fillWidth:true
                        text:shop.selection?.description || ""
                        wrapMode:Text.WordWrap
                        font.family:"Inter"
                        font.pixelSize:UiMetrics.text(13)
                        color:"#f3deee"
                    }
                    ActionButton {
                        objectName:"refundWitchRank"
                        visible:!!shop.selection?.cap && Meta.level(shop.shown,shop.selection.id)>0
                        text: {
                            const id=shop.selection?.id || ""
                            const legacy=Meta.level(shop.shown,id)>0 && Meta.level(shop.shown,id)<=shop.shown.legacyReceipts[id]
                            return "Refund one rank · ◆ "+Meta.refundValue(shop.shown,id)+(legacy ? " (legacy estimate)" : "")
                        }
                        hintText:"Right-click an owned permanent upgrade to refund its last rank."
                        onClicked:shop.refund(shop.selection)
                    }
                    RowLayout {
                        Layout.fillWidth:true
                        Text {
                            Layout.fillWidth:true
                            text:!shop.selection ? "" : shop.selection.cap
                                ? (Meta.level(shop.shown,shop.selection.id)>=shop.selection.cap ? "Fully inscribed" : "Right-click an owned upgrade to refund one rank")
                                : shop.shown.pending[shop.selection.id] ? "Temporary · reserved for your next run"
                                : shop.selection.wave && Meta.startWave(shop.shown)>1 ? "A passage is already reserved"
                                : shop.selection.rarity && (shop.shown.pending.epic || shop.shown.pending.legendary)
                                    ? "A starting weapon is already reserved" : "One use on your next regular run"
                            wrapMode:Text.WordWrap
                            color:"#d1b5cc"
                            font.family:"Inter"
                            font.pixelSize:UiMetrics.text(11)
                        }
                        ActionButton {
                            objectName:"buyWitchUpgrade"
                            enabled:shop.eligible
                            primary:true
                            accent:"#d1a6ec"
                            text: {
                                const item=shop.selection
                                if (!item) return ""
                                if (item.cap && Meta.level(shop.shown,item.id)>=item.cap) return "Max rank"
                                if (!item.cap && shop.shown.pending[item.id]) return "Reserved"
                                const price=Meta.price(shop.shown,item)
                                return price ? "Buy · ◆ "+price : "Claim free"
                            }
                            onClicked:shop.buy(shop.selection.id)
                        }
                    }
                }
            }
        }
    }
}

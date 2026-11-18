pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Meta.js" as Meta
import "../game/Tarot.js" as Tarot

Item {
    id: table
    required property var ledger
    property bool motion: true
    readonly property var hand: ledger.reading
    readonly property var chosen: Tarot.card(hand?.chosen || "")
    signal buyRequested()
    signal turnRequested(string id)

    ColumnLayout {
        anchors.fill:parent
        spacing:8

        Item { Layout.fillHeight:true; visible:!table.hand }
        Text {
            Layout.fillWidth:true
            visible:!table.hand
            text:Meta.reading.title
            font.family:"Cormorant Garamond"
            font.bold:true
            font.pixelSize:UiMetrics.text(25)
            horizontalAlignment:Text.AlignHCenter
            color:"#f6dfc0"
        }
        Text {
            Layout.fillWidth:true
            visible:!table.hand
            text:Meta.reading.description
            font.family:"Inter"
            font.pixelSize:UiMetrics.text(14)
            horizontalAlignment:Text.AlignHCenter
            wrapMode:Text.WordWrap
            color:"#d9c1da"
        }
        SaleSticker {
            Layout.alignment:Qt.AlignHCenter
            sale:Meta.discount(table.ledger,Meta.reading)
            visible:!table.hand && sale>0
        }
        ActionButton {
            objectName:"buyTarotReading"
            Layout.alignment:Qt.AlignHCenter
            visible:!table.hand
            enabled:Meta.canBuy(table.ledger,Meta.reading)
            primary:true
            accent:"#e6b179"
            text:Meta.price(table.ledger,Meta.reading) ? "Draw five · ◆ "+Meta.price(table.ledger,Meta.reading) : "Draw five · Free"
            onClicked:table.buyRequested()
        }
        Item { Layout.fillHeight:true; visible:!table.hand }

        Text {
            Layout.fillWidth:true
            visible:!!table.hand
            text:table.chosen ? "Reserved for your next regular run" : "Turn over one card"
            font.family:"Inter"
            font.pixelSize:UiMetrics.text(13)
            horizontalAlignment:Text.AlignHCenter
            wrapMode:Text.WordWrap
            color:"#e9cbb0"
        }
        Item {
            id: tray
            Layout.fillWidth:true
            Layout.fillHeight:true
            visible:!!table.hand
            Row {
                id: cards
                anchors.centerIn:parent
                spacing:Math.min(11,tray.width*.016)
                Repeater {
                    model:table.hand?.cards || []
                    AbstractButton {
                        id: cardButton
                        required property int index
                        required property string modelData
                        readonly property var face:Tarot.card(modelData)
                        readonly property bool revealed:table.hand?.chosen===modelData
                        width:Math.min((tray.width-4*cards.spacing)/5,tray.height*2/3,144)
                        height:width*1.5
                        objectName:"tarotCard"+index
                        hoverEnabled:true
                        enabled:!!table.hand && !table.hand.chosen
                        Accessible.name:revealed ? face.title : "Face-down tarot card "+(index+1)
                        activeFocusOnTab:true
                        onClicked:table.turnRequested(modelData)

                        Rectangle {
                            anchors.fill:parent
                            anchors.margins:-2
                            radius:5
                            color:"transparent"
                            border.color:"#fbd895"
                            border.width:1.5
                            visible:cardButton.activeFocus || cardButton.hovered || cardButton.revealed
                        }
                        Flipable {
                            anchors.fill:parent
                            opacity:table.chosen && !cardButton.revealed ? .48 : 1
                            front:Image {
                                anchors.fill:parent
                                source:"../art/tarot/back.webp"
                                fillMode:Image.PreserveAspectFit
                            }
                            back:Image {
                                anchors.fill:parent
                                source:cardButton.face ? "../art/tarot/"+String(cardButton.face.art).padStart(2,"0")+".webp" : ""
                                fillMode:Image.PreserveAspectFit
                            }
                            transform:Rotation {
                                origin.x:cardButton.width/2
                                origin.y:cardButton.height/2
                                axis {x:0;y:1;z:0}
                                angle:cardButton.revealed ? 180 : 0
                                Behavior on angle { NumberAnimation {duration:table.motion ? 470 : 0;easing.type:Easing.InOutCubic} }
                            }
                        }
                    }
                }
            }
        }
        Rectangle {
            Layout.fillWidth:true
            Layout.preferredHeight: omen.implicitHeight+16
            visible:!!table.hand
            color:"#2b1e2e"
            radius:7
            border.color:"#76576f"

            Column {
                id: omen
                anchors.top:parent.top
                anchors.left:parent.left
                anchors.right:parent.right
                anchors.margins:8
                spacing:3
                Text {
                    width:parent.width
                    text:table.chosen?.title || "One omen per expedition"
                    color:"#f4c996"
                    font.family:"Cormorant Garamond"
                    font.bold:true
                    font.pixelSize:UiMetrics.text(19)
                    horizontalAlignment:Text.AlignHCenter
                    wrapMode:Text.WordWrap
                }
                Text {
                    width:parent.width
                    text:table.chosen?.description || "Leave whenever you like. Your hand will still be here."
                    color:"#f4e3e7"
                    font.family:"Inter"
                    font.pixelSize:UiMetrics.text(13)
                    horizontalAlignment:Text.AlignHCenter
                    wrapMode:Text.WordWrap
                }
            }
        }
    }
}

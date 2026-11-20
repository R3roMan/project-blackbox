pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Meta.js" as Meta

Rectangle {
    id: card
    objectName:"runPostcard"
    required property var report
    property bool reviewing: false
    property bool reviewExit:true
    property bool archived: false
    signal restartRequested()
    signal archiveRequested()
    signal exitRequested()
    readonly property bool compact: width<680 || height<505
    readonly property color stamp:Meta.colors[Meta.familyOf(report?.grades?.overall || "")] || "#d4abb0"
    radius:InterfaceTheme.current.radius
    gradient:Gradient {
        GradientStop {position:0;color:InterfaceTheme.current.surface}
        GradientStop {position:1;color:InterfaceTheme.current.base}
    }
    border.color:InterfaceTheme.current.line
    PanelPlating {anchors.fill:parent;tone:InterfaceTheme.current.line;blood:InterfaceTheme.current.blood}

    ColumnLayout {
        anchors.fill:parent
        anchors.margins:card.compact ? 12 : 24
        spacing:card.compact ? 8 : 14
        Text {
            Layout.fillWidth:true
            text:card.reviewing ? "Expedition record" : card.report?.reason==="retired" ? "Returned from the Shrine" : "Postcard from the Shrine"
            color:"#ffe8c9"
            font.family:"Cormorant Garamond"
            font.bold:true
            font.pixelSize:UiMetrics.text(card.compact ? 26 : 36)
            wrapMode:Text.WordWrap
        }
        Text {
            Layout.fillWidth:true
            text:card.report ? "Wave "+card.report.wave+"  ·  "+card.report.difficulty.toUpperCase()
                +"  ·  "+card.report.cleared+" cleared" : ""
            color:"#d8c4ba"
            font.family:"IBM Plex Mono"
            font.pixelSize:UiMetrics.text(12)
        }
        RowLayout {
            Layout.fillWidth:true
            spacing:12
            ColumnLayout {
                Layout.fillWidth:true
                spacing:3
                Repeater {
                    model:["skill","finance","survival"]
                    RowLayout {
                        required property string modelData
                        Layout.fillWidth:true
                        Text {
                            Layout.fillWidth:true
                            text:parent.modelData.toUpperCase()
                            color:"#e7c7b0"
                            font.family:"IBM Plex Mono"
                            font.pixelSize:UiMetrics.text(13)
                            font.letterSpacing:1.3
                        }
                        Text {
                            readonly property string grade:card.report?.grades[parent.modelData] || "—"
                            text:grade
                            color:Meta.colors[Meta.familyOf(grade)] || "#d7c6d0"
                            font.family:"Archivo Black"
                            font.pixelSize:UiMetrics.text(18)
                        }
                        Text {
                            text:(card.report?.points[parent.modelData] ?? "—")+" / 100"
                            color:"#c4aba6"
                            font.family:"IBM Plex Mono"
                            font.pixelSize:UiMetrics.text(11)
                            Layout.preferredWidth:UiMetrics.text(75)
                            horizontalAlignment:Text.AlignRight
                        }
                    }
                }
            }
            Rectangle {
                Layout.preferredWidth:UiMetrics.text(card.compact ? 135 : 157)
                Layout.preferredHeight:UiMetrics.text(105)
                color:"#201820"
                radius:7
                border.color:card.stamp
                Column {
                    anchors.centerIn:parent
                    spacing:1
                    Text {
                        anchors.horizontalCenter:parent.horizontalCenter
                        text:"OVERALL"
                        color:"#e7c7b0"
                        font.family:"IBM Plex Mono"
                        font.letterSpacing:2
                        font.pixelSize:UiMetrics.text(11)
                    }
                    Text {
                        objectName:"overallGrade"
                        anchors.horizontalCenter:parent.horizontalCenter
                        text:card.report?.grades?.overall || "—"
                        color:card.stamp
                        font.family:"Archivo Black"
                        font.pixelSize:UiMetrics.text(card.compact ? 43 : 53)
                    }
                }
            }
        }
        Text {
            Layout.fillWidth:true
            text:card.report?.eligible ? "◆ "+card.report.gems+" dark gems  ·  "+card.report.bonus+" expedition bonus"
                +(card.report.stats.autoTaxRate ? "  ·  Auto tax "+card.report.stats.autoTaxRate+"%" : "")
                : "Practice report · no dark gems awarded"
            color:"#e9c0fa"
            font.bold:true
            font.family:"Inter"
            font.pixelSize:UiMetrics.text(13)
            wrapMode:Text.WordWrap
        }
        ScrollView {
            Layout.fillWidth:true
            Layout.fillHeight:true
            contentWidth:availableWidth
            clip:true
            ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
            GridLayout {
                width:parent.width
                columns:2
                columnSpacing:15
                rowSpacing:4
                Repeater {
                    model: {
                        const s=card.report?.stats
                        if (!s) return []
                        return [["Accuracy",s.accuracy+"% ("+s.hits+"/"+s.shots+")"],["Damage taken",s.damage+" HP"],
                            ["Unblocked hits",s.contacts],["Demons killed",s.kills],["Bosses defeated",s.bosses],["Abyss seals",s.seals],
                            ["Shield blocks",s.blocks],["Perfect parries",s.parries],["Projectiles intercepted",s.intercepts],["Shop purchases",s.purchases],
                            ["Gold earned",s.earned],["Gold spent in shops",s.spent],["Gold left",s.wallet],["Hitless waves",s.flawless],
                            ["Items owned",s.items],["Gear and slot upgrades",s.upgrades],["Light-loadout bonus","+"+s.restraint],["Wave score",s.waveScore===undefined ? "—" : s.waveScore+" / 100"]].concat(s.waveGems===undefined ? [] : [["Wave clear gems",s.waveGems],["Combat gems",s.combatGems],["Field gems banked",s.fieldGems || 0],["Difficulty bonus",s.difficultyBonus || 0],["Auto tax",s.autoTax ? "−"+s.autoTax : "0"]])
                    }
                    RowLayout {
                        required property var modelData
                        Layout.fillWidth:true
                        Text {
                            Layout.fillWidth:true
                            text:modelData[0]
                            color:"#d8c5bc"
                            font.family:"Inter"
                            font.pixelSize:UiMetrics.text(12)
                            wrapMode:Text.WordWrap
                        }
                        Text {
                            text:modelData[1]
                            color:"#ffead1"
                            font.family:"IBM Plex Mono"
                            font.pixelSize:UiMetrics.text(12)
                        }
                    }
                }
            }
        }
        Flow {
            Layout.fillWidth:true
            spacing:6
            ActionButton {objectName:"primaryPlayAction";visible:!card.reviewing;text:"Restart";primary:true;onClicked:card.restartRequested()}
            ActionButton {
                objectName:"saveAttempt"
                visible:!card.reviewing
                enabled:!!card.report?.eligible && !card.archived
                text:card.archived ? "Attempt saved" : "Save attempt"
                onClicked:card.archiveRequested()
            }
            ActionButton {objectName:"exitPostcard";visible:!card.reviewing || card.reviewExit;text:card.reviewing ? "Back" : "Exit";onClicked:card.exitRequested()}
        }
    }
}

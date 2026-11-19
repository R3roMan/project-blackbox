import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game" as Game
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Pets.js" as Pets
import "../game/Progress.js" as Progress
import "../game/Encounters.js" as Encounters
import "../game/Conditions.js" as Conditions
import "CodexData.js" as Book

FocusScope {
    id: page
    objectName: "referencePage"
    required property url artDirectory
    required property string firstTab
    required property var known
    required property var unlocks
    property string firstEntry: ""
    property bool sound:false
    property real lastPaper:0
    Game.CuePlayer {id:paper;allowed:page.sound;capacity:6}

    function soundScroll() {
        const now=Date.now()
        if (now-lastPaper<125) return
        lastPaper=now
        paper.play("book-scroll",.52)
    }

    property var career: ({})
    property var liveRun:null
    property int liveRevision:0
    property var nextTerms:null
    property bool achievementsUnlocked: false
    property bool motion: true
    property bool overlay: false
    signal unlockToggleRequested()
    signal closeRequested()
    property string tab: firstTab
    property string enemyTier: "All"
    property bool revealAll: false
    property string enemyOrigin: "All"
    property string enemySort: "Debut wave"
    property string weaponClass: "All"
    property string weaponSort: "Name"
    property int pageIndex: 0

    property real opening: 0
    property real flip: 0
    property int flipDirection: 1
    property bool closing: false
    property int pendingPage: 0
    property var history: []
    readonly property bool compact: width < 880 || height < 625
    readonly property color ink: "#352125"
    readonly property int paperText: UiMetrics.text(compact ? 15 : 17)
    readonly property string chapterTitle: Book.chapters.find(function(chapter) { return chapter.id === tab })?.title || ""
    readonly property var enemyEntries: Object.values(Rules.enemyTypes).filter(function(e) {
        return !["meteor","hallucination"].includes(e.id) && (enemyTier === "All" || Encounters.tier(e.id) === enemyTier)
            && (enemyOrigin === "All" || e.origin === enemyOrigin)
    }).sort(function(a,b) {
        const key = enemySort === "Kills" ? "enemyKills_" : "enemyDeaths_"
        const first = Encounters.firstWave(a.id), second = Encounters.firstWave(b.id)
        const debutOrder = (first < 0 ? 10000 : first)-(second < 0 ? 10000 : second)
        return (enemySort === "Debut wave" ? debutOrder : enemySort === "Name" ? 0
            : (career[key+b.id] || 0)-(career[key+a.id] || 0)) || a.title.localeCompare(b.title)
    })
    readonly property var weaponEntries: Object.values(Gear.weapons).filter(function(w) {
        return !w.debugOnly && (weaponClass === "All" || Gear.weaponClass(w) === weaponClass)
    }).sort(function(a,b) {
        return (weaponSort === "Kills" ? (career["weaponKills_"+b.id] || 0)-(career["weaponKills_"+a.id] || 0) : 0)
            || a.title.localeCompare(b.title)
    })
    readonly property var abilityEntries:Object.values(Gear.activeAbilities).concat(Object.values(Gear.passives))
        .sort(function(a,b) {return a.title.localeCompare(b.title)})
    readonly property var shopEntries:Gear.shopEntries()
    readonly property var displayed: tab === "enemies" ? enemyEntries : tab === "weapons" ? weaponEntries
        : tab === "abilities" ? abilityEntries : tab === "weather" ? Object.values(Conditions.entries)
        : tab === "pets" ? Pets.pets : tab === "achievements" ? Progress.achievements
        : tab === "kits" ? Book.kitEntries() : tab === "shop" ? shopEntries : Book.manual
    readonly property var entry: displayed[Math.max(0,Math.min(pageIndex,displayed.length-1))] || null
    readonly property bool seen: visibleEntry(entry)
    readonly property bool controller: tab === "controls" && entry?.id === "controller"
    readonly property color tierColor: entry && tab === "enemies" && Rules.enemyTypes[entry.id] ? Encounters.tierColors[Encounters.tier(entry.id)]
        : entry && entry.rarity ? Gear.rarities[entry.rarity]?.color || "#af7957" : "#984b41"
    readonly property string heading: !entry ? "An empty chapter" : seen ? entry.title : "Unknown"
    readonly property string description: {
        liveRevision
        return !entry ? "There is nothing written here yet."
            : !seen ? "Its name has yet to reach these pages. Meet it in the field."
            : Book.entryText(entry,tab,liveRun,nextTerms)
    }
    readonly property string caption: !seen || !entry ? "" : tab === "enemies" && Rules.enemyTypes[entry.id]
        ? entry.origin+" · "+Encounters.tier(entry.id)+" · "+(Encounters.firstWave(entry.id) === 0
            ? "Tutorial" : Encounters.firstWave(entry.id) === -1 ? "Blood Moon" : "Wave "+Encounters.firstWave(entry.id))
        : tab === "weapons" ? Gear.weaponClass(entry)+" · "+Gear.rarities[entry.rarity].label
        : tab === "abilities" ? entry.category+(entry.rarity ? " · "+Gear.rarities[entry.rarity].label : "")
        : tab === "pets" ? "Companion" : tab === "kits" ? "Three-piece set"
        : tab === "shop" ? (entry.group ? Gear.groupLabels[entry.group]+" · " : "")+entry.category : chapterTitle

    function visibleEntry(record) {
        if (!record) return false
        if (revealAll) return true
        if (tab === "enemies") return known.enemies.includes(record.id)
        if (tab === "abilities") return known.abilities.includes(record.id) || unlocks.includes(record.id) || !record.locked
        return true
    }

    function closeBook() {
        if (closing) return
        closing = true
        paper.play("book-close",.65)
        if (!motion) {
            closeRequested()
            return
        }
        coverOpen.stop()
        coverClose.start()
    }

    function rememberPage() {
        history = history.concat([{chapter:tab,id:entry?.id || "",origin:enemyOrigin,tier:enemyTier,
            weaponClass:weaponClass,enemySort:enemySort,weaponSort:weaponSort}]).slice(-30)
    }

    function showEntry(chapter, id) {
        const changed = tab !== chapter
        tab = chapter
        let index = displayed.findIndex(function(record) { return record.id === id })
        if (id && index < 0 && chapter === "enemies" && Rules.enemyTypes[id]) {
            enemyTier = enemyOrigin = "All"
            index = displayed.findIndex(function(record) { return record.id === id })
        } else if (id && index < 0 && chapter === "weapons" && Gear.weapons[id]) {
            weaponClass = "All"
            index = displayed.findIndex(function(record) { return record.id === id })
        }
        if (id && index < 0) return false
        pageIndex = Math.max(0,index)
        if (changed && motion) {
            flipDirection = 1
            skipPages.restart()
        }
        return true
    }

    function jumpTo(chapter, id) {
        if (closing || !Book.chapters.some(function(record) { return record.id === chapter })
            || chapter === tab && (!id || entry?.id === id)) return
        turnPages.stop()
        skipPages.stop()
        flip = 0
        rememberPage()
        paper.play(chapter!==tab ? "book-sweep" : "book-flip",.70)
        if (!showEntry(chapter,id))
            back()
    }

    function follow(destination) {
        const slash = destination.indexOf("/")
        if (slash > 0)
            jumpTo(destination.slice(0,slash),decodeURIComponent(destination.slice(slash+1)))
    }

    function back() {
        if (!history.length || closing) return
        turnPages.stop()
        skipPages.stop()
        flip = 0
        const previous = history[history.length-1]
        history = history.slice(0,-1)
        enemyOrigin = previous.origin
        enemyTier = previous.tier
        weaponClass = previous.weaponClass
        enemySort = previous.enemySort
        weaponSort = previous.weaponSort
        paper.play(previous.chapter!==tab ? "book-sweep" : "book-flip",.70)
        showEntry(previous.chapter,previous.id)
    }

    function turnTo(index) {
        if (closing || turnPages.running || !displayed.length) return
        pendingPage = Math.max(0,Math.min(displayed.length-1,index))
        if (pendingPage === pageIndex) return
        paper.play("book-flip",.70)
        flipDirection = pendingPage > pageIndex ? 1 : -1
        skipPages.stop()
        if (motion)
            turnPages.start()
        else
            pageIndex = pendingPage
    }

    onTabChanged: pageIndex = 0
    onEnemyTierChanged: pageIndex = 0
    onEnemyOriginChanged: pageIndex = 0
    onWeaponClassChanged: pageIndex = 0
    Shortcut { sequence:"Escape"; enabled:!page.closing; onActivated:page.closeBook() }
    Shortcut { sequence:"Alt+Left"; enabled:page.history.length > 0; onActivated:page.back() }
    Shortcut { sequence:"Left"; enabled:page.activeFocus && !leafPicker.popup.visible; onActivated:page.turnTo(page.pageIndex-1) }
    Shortcut { sequence:"Right"; enabled:page.activeFocus && !leafPicker.popup.visible; onActivated:page.turnTo(page.pageIndex+1) }
    Component.onCompleted: {
        paper.play("book-open",.65)
        if (firstEntry.length)
            showEntry(firstTab,firstEntry)
        if (motion)
            coverOpen.start()
        else
            opening = 1
        forceActiveFocus()
    }

    NumberAnimation { id:coverOpen; target:page; property:"opening"; from:0; to:1; duration:900; easing.type:Easing.InOutCubic }
    SequentialAnimation {
        id:coverClose
        NumberAnimation { target:page; property:"opening"; to:0; duration:620; easing.type:Easing.InOutCubic }
        ScriptAction { script:page.closeRequested() }
    }
    SequentialAnimation {
        id:turnPages
        NumberAnimation { target:page; property:"flip"; from:0; to:.5; duration:170; easing.type:Easing.InQuad }
        ScriptAction { script:page.pageIndex=page.pendingPage }
        NumberAnimation { target:page; property:"flip"; to:1; duration:175; easing.type:Easing.OutQuad }
        ScriptAction { script:page.flip=0 }
    }
    SequentialAnimation {
        id:skipPages
        loops:4
        NumberAnimation { target:page; property:"flip"; from:0; to:1; duration:110 }
        ScriptAction { script:page.flip=0 }
    }

    Rectangle { anchors.fill:parent; color:page.overlay ? "#ec130d15" : "#130e16" }
    Image { anchors.fill:parent; source:String(page.artDirectory)+"shrine.png"; fillMode:Image.PreserveAspectCrop; opacity:page.overlay ? 0 : .12; sourceSize.width:1440 }
    MouseArea { anchors.fill:parent; acceptedButtons:Qt.AllButtons; onWheel:function(wheel){wheel.accepted=true} }

    ColumnLayout {
        id:frame
        width:Math.min(parent.width-(page.compact ? 20 : 44),1350)
        anchors.horizontalCenter:parent.horizontalCenter
        anchors.top:parent.top
        anchors.bottom:parent.bottom
        anchors.margins:page.compact ? 9 : 20
        spacing:page.compact ? 5 : 9

        RowLayout {
            Layout.fillWidth:true
            spacing:7
            Text {
                Layout.fillWidth:true
                text:"The Black Grimoire"
                color:"#f1d4b1"
                font.family:"DejaVu Serif"
                font.pixelSize:UiMetrics.text(page.compact ? 20 : 28)
                font.bold:true
                elide:Text.ElideRight
            }
            ActionButton {
                objectName:"referenceBack"
                text:"↶ Back"
                visible:page.history.length>0
                onClicked:page.back()
            }
            ActionButton { objectName:"revealGallery"; text:page.revealAll ? "Show discoveries" : "Reveal all"; primary:page.revealAll; onClicked:page.revealAll=!page.revealAll }
            ActionButton {
                objectName:"unlockAchievements"
                text:page.achievementsUnlocked ? "Restore earned" : "Debug unlocks"
                visible:page.tab==="achievements"
                primary:page.achievementsUnlocked
                hintText:"Toggle achievement rewards for future runs. Your earned progress is preserved."
                onClicked:page.unlockToggleRequested()
            }
            ActionButton { objectName:"closeReference"; text:page.overlay ? "Return to run" : "Close"; onClicked:page.closeBook() }
        }

        Flow {
            Layout.alignment:Qt.AlignHCenter
            Layout.fillWidth:true
            Layout.preferredHeight:childrenRect.height
            spacing:5
            Repeater {
                model:Book.chapters
                ActionButton {
                    required property var modelData
                    objectName:"gallery-"+modelData.id
                    text:modelData.title
                    leftPadding:page.compact ? 9 : 13
                    rightPadding:leftPadding
                    implicitHeight:Math.max(29,UiMetrics.text(15)+12)
                    primary:page.tab===modelData.id
                    onClicked:page.jumpTo(modelData.id,"")
                }
            }
        }

        RowLayout {
            Layout.alignment:Qt.AlignHCenter
            spacing:5
            visible:page.tab==="enemies" || page.tab==="weapons"
            LeafPicker {
                objectName:"galleryOriginFilter"
                visible:page.tab==="enemies"
                model:["All origins","Hellborne","Space","Void"]
                currentIndex:Math.max(0,model.indexOf(page.enemyOrigin))
                onActivated:page.enemyOrigin=currentIndex ? currentText : "All"
            }
            LeafPicker {
                objectName:"galleryWeaponFilter"
                visible:page.tab==="weapons"
                model:["All weapons","Guns","Staffs","Melee"]
                currentIndex:Math.max(0,model.indexOf(page.weaponClass))
                onActivated:page.weaponClass=currentIndex ? currentText : "All"
            }
            LeafPicker {
                visible:page.tab==="enemies"
                model:["All ranks","Normal","Ascended","Nightmare","Overlord"]
                currentIndex:Math.max(0,model.indexOf(page.enemyTier))
                onActivated:page.enemyTier=currentIndex ? currentText : "All"
            }
            LeafPicker {
                objectName:"galleryStatsSort"
                model:page.tab==="enemies" ? ["Debut wave","Name","Kills","Deaths"] : ["Name","Kills"]
                currentIndex:model.indexOf(page.tab==="enemies" ? page.enemySort : page.weaponSort)
                onActivated:if (page.tab==="enemies") page.enemySort=currentText; else page.weaponSort=currentText
            }
        }

        Item {
            id: bookArea
            Layout.fillWidth:true
            Layout.fillHeight:true
            Rectangle {
                id: binding
                objectName:"hardcoverBook"
                anchors.centerIn:parent
                width:Math.min(parent.width-12,Math.max(484,parent.height*1.56))
                height:Math.min(parent.height-3,width/1.27)
                radius:9
                color:"transparent"
                opacity:1
                scale:.9+.1*page.opening

                Rectangle {
                    x:page.opening<.92 ? parent.width/2-2 : 0
                    width:parent.width-x
                    height:parent.height
                    y:2
                    radius:6
                    color:"#160f14"
                    border.color:"#8d5a42"
                }
                Repeater {
                    model:5
                    Rectangle {
                        required property int index
                        x:(page.opening<.92 ? binding.width/2 : 14)+index*.6; y:11+index*2
                        width:binding.width-x-14-index*.6; height:binding.height-22
                        radius:2
                        color:index%2 ? "#9e7954" : "#c1a17a"
                    }
                }
                Item {
                    id: leaves
                    anchors.fill:parent
                    anchors.leftMargin:14
                    anchors.rightMargin:14
                    anchors.topMargin:10
                    anchors.bottomMargin:21
                    opacity:1
                    Row {
                        anchors.fill:parent
                        BookPaper { width:parent.width/2; height:parent.height; seed:page.entry?.id.length || 0; opacity:page.opening>=.92 ? 1 : 0 }
                        BookPaper { width:parent.width/2; height:parent.height; seed:page.entry?.id.length || 0; rightPage:true }
                    }
                    Rectangle {
                        anchors.horizontalCenter:parent.horizontalCenter
                        height:parent.height
                        width:12
                        visible:page.opening>=.92
                        gradient:Gradient {
                            orientation:Gradient.Horizontal
                            GradientStop { position:0; color:"#00513a2e" }
                            GradientStop { position:.49; color:"#6a513a2e" }
                            GradientStop { position:.51; color:"#a2574230" }
                            GradientStop { position:1; color:"#00513a2e" }
                        }
                    }

                    RowLayout {
                        anchors.fill:parent
                        anchors.leftMargin:page.compact ? 15 : 22
                        anchors.rightMargin:anchors.leftMargin
                        anchors.topMargin:page.compact ? 10 : 17
                        anchors.bottomMargin:38
                        spacing:page.compact ? 24 : 36
                        visible:!page.controller && page.opening>=.92
                        opacity:1-Math.sin(page.flip*Math.PI)*.38
                        enabled:!page.closing && page.opening > .65 && !turnPages.running

                        ColumnLayout {
                            Layout.fillWidth:true
                            Layout.fillHeight:true
                            Layout.preferredWidth:1
                            spacing:6
                            Text {
                                Layout.alignment:Qt.AlignHCenter
                                text:page.chapterTitle.toUpperCase()
                                color:"#6d4139"
                                font.family:"DejaVu Serif"
                                font.letterSpacing:2
                                font.pixelSize:UiMetrics.text(12)
                            }
                            Item {
                                Layout.fillWidth:true
                                Layout.fillHeight:true
                                Rectangle {
                                    id: artFrame
                                    anchors.centerIn:parent
                                    width:Math.min(parent.width,parent.height*1.23)
                                    height:parent.height
                                    color:"#9fe5d1ac"
                                    border.color:Qt.darker(page.tierColor,1.35)
                                    radius:3
                                    Loader {
                                        anchors.fill:parent
                                        anchors.margins:5
                                        active:page.seen && !!page.entry
                                        sourceComponent:page.tab==="achievements" ? medalArt : page.tab==="kits" ? kitArt
                                            : page.tab==="controls" ? manualArt : sketchArt
                                    }
                                    Text {
                                        anchors.centerIn:parent
                                        text:"?"
                                        visible:!page.seen
                                        font.family:"DejaVu Serif"
                                        font.italic:true
                                        font.pixelSize:Math.min(parent.width,parent.height)*.68
                                        color:"#784844"
                                        rotation:-9
                                    }
                                }
                            }
                            Text {
                                Layout.fillWidth:true
                                visible:page.caption.length>0
                                wrapMode:Text.WordWrap
                                horizontalAlignment:Text.AlignHCenter
                                text:page.caption
                                color:"#6b3733"
                                font.family:"DejaVu Serif"
                                font.pixelSize:UiMetrics.text(12)
                                font.bold:true
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth:true
                            Layout.fillHeight:true
                            Layout.preferredWidth:1
                            spacing:page.compact ? 6 : 11
                            Text {
                                objectName:"bookEntryTitle"
                                text:page.heading
                                color:page.ink
                                font.family:"DejaVu Serif"
                                font.pixelSize:UiMetrics.text(page.compact ? 20 : 27)
                                font.bold:true
                                Layout.fillWidth:true
                                maximumLineCount:2
                                elide:Text.ElideRight
                                wrapMode:Text.WordWrap
                            }
                            Rectangle { Layout.fillWidth:true; height:1; color:"#a46a58" }
                            ScrollView {
                                id: descriptionScroll
                                objectName:"bookDescriptionScroll"
                                Layout.fillWidth:true
                                Layout.fillHeight:true
                                contentWidth:availableWidth
                                clip:true
                                ScrollBar.horizontal.policy:ScrollBar.AlwaysOff
                                WheelHandler {
                                    blocking:false
                                    onWheel:if (descriptionScroll.contentHeight>descriptionScroll.availableHeight) page.soundScroll()
                                }
                                Text {
                                    objectName:"bookDescription"
                                    width:Math.max(0,descriptionScroll.availableWidth-11)
                                    text:page.description
                                    textFormat:Text.RichText
                                    color:page.ink
                                    font.family:"DejaVu Serif"
                                    font.pixelSize:page.paperText
                                    lineHeight:1.12
                                    wrapMode:Text.WordWrap
                                    onLinkActivated:function(destination) { page.follow(destination) }
                                    HoverHandler { cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor }
                                    onTextChanged:if (descriptionScroll.contentItem) descriptionScroll.contentItem.contentY = 0
                                }
                            }
                            Text {
                                visible:page.seen && ["enemies","weapons","achievements"].includes(page.tab)
                                Layout.fillWidth:true
                                wrapMode:Text.WordWrap
                                color:"#753a34"
                                font.family:"DejaVu Serif"
                                font.pixelSize:UiMetrics.text(12)
                                text:!page.entry ? "" : page.tab==="enemies" ? "Slain "+(page.career["enemyKills_"+page.entry.id]||0)
                                    +" · Deaths "+(page.career["enemyDeaths_"+page.entry.id]||0)
                                    : page.tab==="weapons" ? "Kills with this weapon "+(page.career["weaponKills_"+page.entry.id]||0)
                                    : Math.min(page.entry.target,Math.max(page.career[page.entry.metric]||0,page.career[page.entry.legacyMetric]||0))+" / "+page.entry.target
                                        +(page.achievementsUnlocked || Progress.complete(page.career,page.entry) ? " · Unlocked" : "")
                            }
                        }
                    }
                    Loader {
                        anchors.fill:parent
                        anchors.margins:13
                        anchors.bottomMargin:40
                        active:page.controller && page.opening>=.92
                        sourceComponent:ScrollView {
                            contentWidth:availableWidth
                            clip:true
                            ControllerReference { width:parent.width; height:width>660 ? 410 : 510 }
                        }
                    }

                    PageCorner {
                        visible:page.opening>=.92
                        objectName:"bookPrevious"
                        anchors.left:parent.left
                        anchors.bottom:parent.bottom
                        backwards:true
                        enabled:page.pageIndex>0 && !page.closing
                        onClicked:page.turnTo(page.pageIndex-1)
                    }
                    PageCorner {
                        visible:page.opening>=.92
                        objectName:"bookNext"
                        anchors.right:parent.right
                        anchors.bottom:parent.bottom
                        enabled:page.pageIndex<page.displayed.length-1 && !page.closing
                        onClicked:page.turnTo(page.pageIndex+1)
                    }
                    Text {
                        anchors.horizontalCenter:parent.horizontalCenter
                        anchors.bottom:parent.bottom
                        anchors.bottomMargin:9
                        visible:page.opening>=.92
                        text:(page.displayed.length ? page.pageIndex+1 : 0)+" / "+page.displayed.length
                        color:"#5b3930"
                        font.family:"DejaVu Serif"
                        font.pixelSize:UiMetrics.text(12)
                    }
                    Rectangle {
                        width:parent.width/2
                        height:parent.height
                        x:page.flipDirection>0 ? parent.width/2 : 0
                        visible:page.flip>0
                        color:"#d6bd91"
                        opacity:.88*Math.sin(page.flip*Math.PI)
                        border.color:"#a48568"
                        transform:Rotation {
                            origin.x:page.flipDirection>0 ? 0 : leaves.width/2
                            origin.y:leaves.height/2
                            axis {x:0;y:1;z:0}
                            angle:-page.flipDirection*180*page.flip
                        }
                    }
                }

                Rectangle {
                    id: cover
                    width:binding.width*.52
                    height:binding.height
                    x:binding.width*.48
                    visible:page.opening<.995
                    readonly property bool frontFace:page.opening<.50
                    color:frontFace ? "#241720" : "#d4b78b"
                    border.color:frontFace ? "#815342" : "#a88a62"
                    border.width:6
                    radius:8
                    z:5
                    transform:Rotation {
                        origin.x:0
                        origin.y:cover.height/2
                        axis {x:0;y:1;z:0}
                        angle:-180*page.opening
                    }
                    BookPaper {
                        anchors.fill:parent
                        anchors.margins:6
                        visible:!cover.frontFace
                    }
                    Rectangle { anchors.fill:parent; anchors.margins:13; color:"transparent"; border.color:"#795340"; radius:3; visible:cover.frontFace }
                    Rectangle {
                        anchors.left:parent.left
                        anchors.top:parent.top
                        anchors.bottom:parent.bottom
                        visible:cover.frontFace
                        width:Math.max(12,parent.width*.071)
                        radius:4
                        gradient:Gradient {
                            orientation:Gradient.Horizontal
                            GradientStop {position:0; color:"#5e3e3c"}
                            GradientStop {position:.5; color:"#2b1c20"}
                            GradientStop {position:1; color:"#110b10"}
                        }
                    }
                    Text {
                        anchors.top:parent.top
                        anchors.topMargin:parent.height*.14
                        anchors.horizontalCenter:parent.horizontalCenter
                        visible:cover.frontFace
                        text:"BLACK GRIMOIRE"
                        font.family:"DejaVu Serif"
                        font.pixelSize:Math.min(parent.width*.072,UiMetrics.text(25))
                        font.letterSpacing:2
                        font.bold:true
                        color:"#dab087"
                    }
                    Canvas {
                        anchors.centerIn:parent
                        visible:cover.frontFace
                        width:Math.min(parent.width*.67,parent.height*.53)
                        height:width
                        onPaint: {
                            const c=getContext("2d"), r=width*.41
                            c.reset()
                            c.translate(width/2,height/2)
                            c.strokeStyle="#b62438"
                            c.lineWidth=Math.max(2,width*.025)
                            c.beginPath()
                            c.arc(0,0,r,0,Math.PI*2)
                            c.stroke()
                            c.beginPath()
                            for (let i=0;i<=5;i++) {
                                const a=-Math.PI/2+i*Math.PI*.8
                                c.lineTo(Math.cos(a)*r,Math.sin(a)*r)
                            }
                            c.stroke()
                        }
                    }
                    BloodStain { anchors.bottom:parent.bottom; anchors.right:parent.right; width:parent.width*.5; height:width*.45; visible:cover.frontFace; mirrorX:true; mirrorY:true }
                }
            }
        }

        LeafPicker {
            id:leafPicker
            objectName:"bookLeafPicker"
            Layout.alignment:Qt.AlignHCenter
            Layout.maximumWidth:Math.min(frame.width,500)
            implicitContentWidthPolicy:ComboBox.WidestText
            model:page.displayed.map(function(record) { return page.visibleEntry(record) ? record.title : "Unknown" })
            currentIndex:page.pageIndex
            onActivated:page.turnTo(currentIndex)
            Accessible.name:"Jump to a page in "+page.chapterTitle
        }
    }

    component LeafPicker: ComboBox {
        id:picker
        font.family:"Inter"
        font.pixelSize:UiMetrics.text(page.compact ? 12 : 13)
        implicitContentWidthPolicy:ComboBox.WidestText
        implicitHeight:Math.max(30,font.pixelSize+12)
        leftPadding:11
        rightPadding:26
        palette.base:"#231b26"
        palette.window:"#231b26"
        palette.text:"#f6ded0"
        palette.buttonText:"#f6ded0"
        palette.highlight:"#673748"
        contentItem:Text {
            text:picker.displayText
            font:picker.font
            color:"#f6ded0"
            verticalAlignment:Text.AlignVCenter
            elide:Text.ElideRight
        }
        indicator:Text {
            text:"⌄"
            x:picker.width-width-9
            y:Math.round((picker.height-height)*.5)-2
            font.pixelSize:18
            color:"#e3b994"
        }
        delegate:ItemDelegate {
            required property string modelData
            required property int index
            width:picker.width
            text:modelData
            font:picker.font
            highlighted:picker.highlightedIndex===index
            contentItem:Text {
                text:parent.text
                font:parent.font
                color:"#f6ded0"
                verticalAlignment:Text.AlignVCenter
                elide:Text.ElideRight
            }
            background:Rectangle {color:parent.highlighted || parent.hovered ? "#533347" : "#231b26"}
        }
        background:Rectangle {
            radius:5
            color:parent.hovered ? "#382736" : "#241b26"
            border.color:parent.activeFocus ? "#ffc091" : "#76544f"
        }
    }

    component PageCorner: Button {
        id: corner
        property bool backwards:false
        width:Math.max(54,UiMetrics.text(42))
        height:34
        padding:0
        z:2
        hoverEnabled:true
        text:backwards ? "❮" : "❯"
        Accessible.name:backwards ? "Turn to previous page" : "Turn to next page"
        opacity:enabled ? 1 : .25
        font.family:"DejaVu Serif"
        font.pixelSize:UiMetrics.text(25)
        contentItem:Text {
            text:corner.text; font:corner.font
            color:corner.hovered ? "#8e172a" : "#67372e"
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment:Text.AlignVCenter
        }
        background:Canvas {
            onPaint:{
                const c=getContext("2d")
                c.reset()
                c.translate(corner.backwards ? 0 : width,0)
                c.scale(corner.backwards ? 1 : -1,1)
                c.fillStyle="rgba(124,63,51,.23)"
                c.beginPath()
                c.moveTo(0,0); c.lineTo(width, height); c.lineTo(0,height)
                c.closePath(); c.fill()
            }
        }
    }

    Component {
        id:sketchArt
        GalleryPortrait {
            entry:page.entry
            engraved:true
            tint:page.tierColor
            layer.enabled:GraphicsInfo.api!==GraphicsInfo.Software && page.tab!=="abilities"
            layer.effect:ShaderEffect { fragmentShader:Qt.resolvedUrl("../shaders/pencil.frag.qsb") }
        }
    }
    Component {
        id:medalArt
        Medal { medalId:page.entry.id; group:page.entry.group; metric:page.entry.metric; earned:page.achievementsUnlocked || Progress.complete(page.career,page.entry) }
    }
    Component {
        id:manualArt
        Text {
            text:page.entry.id==="look" ? "✥" : page.entry.id==="fight" ? "⚔" : "⌘"
            font.family:"DejaVu Serif"
            font.pixelSize:Math.min(width,height)*.42
            color:"#763a34"
            horizontalAlignment:Text.AlignHCenter
            verticalAlignment:Text.AlignVCenter
        }
    }
    Component {
        id:kitArt
        ColumnLayout {
            spacing:5
            Repeater {
                model:page.tab==="kits" && page.entry
                    ? [Gear.weapons[page.entry.weapon],Gear.activeAbilities[page.entry.active],Gear.passives[page.entry.passive]].filter(Boolean) : []
                GalleryPortrait {
                    required property var modelData
                    entry:modelData
                    engraved:true
                    tint:Gear.rarities[entry.rarity].color
                    Layout.fillWidth:true
                    Layout.fillHeight:true
                    Layout.preferredHeight:1
                    TapHandler { onTapped:page.jumpTo(modelData.category==="Weapon" ? "weapons" : "abilities",modelData.id) }
                    HoverHandler { cursorShape:Qt.PointingHandCursor }
                    Accessible.name:modelData.title
                }
            }
        }
    }
}

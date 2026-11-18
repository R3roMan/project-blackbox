import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Rules.js" as Rules
import "../game/Loadout.js" as Gear
import "../game/Pets.js" as Pets
import "../game/Progress.js" as Progress
import "../game/Encounters.js" as Encounters
import "../game/Conditions.js" as Conditions
import "../game/EnemyLore.js" as Lore

Item {
    id:page
    objectName:"referencePage"
    required property url artDirectory
    required property string firstTab
    required property var known
    required property var unlocks
    property var career:({})
    property bool achievementsUnlocked:false
    signal unlockToggleRequested()
    signal closeRequested()
    property string tab:firstTab
    property string enemyTier:"All"
    property bool revealAll:false
    property string enemyOrigin:"All"
    property string enemySort:"Name"
    property string weaponClass:"All"
    property string weaponSort:"Name"
    property int pageIndex:0
    property real opening:0
    property real flip:0
    property bool closing:false
    property int pendingPage:0
    readonly property var enemyEntries:Object.values(Rules.enemyTypes).filter(function(e){return !["meteor","hallucination"].includes(e.id)
        && (enemyTier==="All" || Encounters.tier(e.id)===enemyTier) && (enemyOrigin==="All" || e.origin===enemyOrigin)
    }).sort(function(a,b){const p=enemySort==="Kills" ? "enemyKills_" : "enemyDeaths_";return (enemySort==="Name" ? 0 : (career[p+b.id]||0)-(career[p+a.id]||0)) || a.title.localeCompare(b.title)})
    readonly property var weaponEntries:Object.values(Gear.weapons).filter(function(w){return !w.debugOnly && (weaponClass==="All" || Gear.weaponClass(w)===weaponClass)})
        .sort(function(a,b){return (weaponSort==="Kills" ? (career["weaponKills_"+b.id]||0)-(career["weaponKills_"+a.id]||0) : 0) || a.title.localeCompare(b.title)})
    readonly property var abilityEntries: {
        const entries=Object.values(Gear.activeAbilities).concat(Object.values(Gear.passives))
        for(const group of Object.keys(Gear.slotPowers))
            for(const power of Gear.slotPowers[group]) entries.push(Object.assign({category:Gear.groupLabels[group]+" slot effect"},Gear.slotPowerAt(power,0)))
        return entries
    }
    readonly property var displayed:tab==="enemies" ? enemyEntries : tab==="weapons" ? weaponEntries : tab==="abilities" ? abilityEntries
        : tab==="weather" ? Object.values(Conditions.entries) : tab==="pets" ? Pets.pets : tab==="achievements" ? Progress.achievements : []
    readonly property var entry:displayed[Math.max(0,Math.min(pageIndex,displayed.length-1))] || null
    readonly property bool seen:!entry ? false : revealAll || tab==="enemies" ? !!entry && (revealAll || known.enemies.includes(entry.id))
        : tab==="abilities" ? known.abilities.includes(entry.id) || unlocks.includes(entry.id) || !entry.locked : true
    readonly property color ink:"#352326"
    readonly property color tierColor:entry && tab==="enemies" ? Encounters.tierColors[Encounters.tier(entry.id)] : entry && entry.rarity ? (Gear.rarities[entry.rarity]?.color || "#ecc0ae") : "#7b3f38"
    readonly property string heading:!entry ? "An empty chapter" : !seen ? "Unknown" : entry.title
    readonly property string description:!entry ? "There is nothing written here yet." : !seen ? "Its name has not reached these pages. Meet it in the field."
        : tab==="weapons" ? Gear.itemDetails(null,"weapon",{id:entry.id,level:0})
        : tab==="abilities" ? (["Active","Passive"].includes(entry.category) ? Gear.itemDetails(null,entry.category==="Active" ? "active" : "passive",{id:entry.id,level:0}) : entry.description)
        : tab==="achievements" ? entry.requirement+"\n\nReward · "+(entry.group==="pet" ? Pets.spec(entry.reward).title : Gear.catalogs[entry.group][entry.reward].title)
        : tab==="enemies" ? entry.description+"\n\nBase stats\nHealth   "+entry.health+" HP     Attack   "+entry.damage
            +"\nMovement   "+entry.speed+" units/s     Reach   "+entry.reach+" units"
            +"\nAttack interval   "+entry.interval+" s     Wind-up   "+entry.windup+" s"
            +(entry.barrier ? "\nBarrier   "+entry.barrier+" HP" : "")
        : entry.description
    function closeBook() {if (!closing) {closing=true;coverClose.start()}}
    function turnTo(index,chapter) {
        if (turnPages.running) return
        if (chapter && chapter!==tab) {tab=chapter;pendingPage=0;pageIndex=0;skipPages.start()}
        else {pendingPage=Math.max(0,Math.min(displayed.length-1,index));if (pendingPage!==pageIndex) turnPages.start()}
    }
    onTabChanged:pageIndex=0
    onEnemyTierChanged:pageIndex=0
    onEnemyOriginChanged:pageIndex=0
    onWeaponClassChanged:pageIndex=0
    Shortcut {sequence:"Escape";onActivated:page.closeBook()}
    Shortcut {sequence:"Left";enabled:tab!=="controls";onActivated:page.turnTo(pageIndex-1,"")}
    Shortcut {sequence:"Right";enabled:tab!=="controls";onActivated:page.turnTo(pageIndex+1,"")}
    Component.onCompleted:coverOpen.start()
    NumberAnimation {id:coverOpen;target:page;property:"opening";from:0;to:1;duration:900;easing.type:Easing.InOutCubic}
    SequentialAnimation {id:coverClose;NumberAnimation {target:page;property:"opening";to:0;duration:620;easing.type:Easing.InOutCubic} ScriptAction {script:page.closeRequested()}}
    SequentialAnimation {id:turnPages;NumberAnimation {target:page;property:"flip";from:0;to:.5;duration:180} ScriptAction {script:page.pageIndex=page.pendingPage} NumberAnimation {target:page;property:"flip";to:1;duration:180} ScriptAction {script:page.flip=0}}
    SequentialAnimation {id:skipPages;loops:4;NumberAnimation {target:page;property:"flip";from:0;to:1;duration:115} ScriptAction {script:page.flip=0}}
    Rectangle {anchors.fill:parent;color:"#110c12"}
    Image {anchors.fill:parent;source:String(page.artDirectory)+"shrine.png";fillMode:Image.PreserveAspectCrop;opacity:.10;sourceSize.width:1440}
    ColumnLayout {
        anchors.fill:parent;anchors.margins:page.width<900 ? 12 : 24;spacing:10
        RowLayout {
            Layout.fillWidth:true
            Text {text:page.tab==="controls" ? "Field manual" : "THE BLACK GRIMOIRE";color:"#e7c8a6";font.family:"serif";font.pixelSize:page.width<900 ? 22 : 30;font.letterSpacing:2;Layout.fillWidth:true}
            ActionButton {objectName:"revealGallery";text:page.revealAll ? "Discoveries" : "Reveal all";visible:page.tab!=="controls";primary:page.revealAll;onClicked:page.revealAll=!page.revealAll}
            ActionButton {objectName:"unlockAchievements";text:page.achievementsUnlocked ? "Restore earned" : "Debug unlocks";primary:page.achievementsUnlocked;hintText:"Toggle all achievement rewards for future runs. Your earned progress is preserved.";onClicked:page.unlockToggleRequested()}
            ActionButton {text:"Close · Esc";onClicked:page.closeBook()}
        }
        Flow {
            Layout.fillWidth:true;Layout.preferredHeight:childrenRect.height;spacing:5
            Repeater {model:[{id:"enemies",title:"Demons"},{id:"weapons",title:"Weapons"},{id:"abilities",title:"Abilities"},{id:"pets",title:"Pets"},{id:"kits",title:"Kits"},{id:"weather",title:"Weather"},{id:"achievements",title:"Medals"},{id:"controls",title:"Controls"}]
                ActionButton {required property var modelData;objectName:"gallery-"+modelData.id;text:modelData.title;implicitHeight:32;primary:page.tab===modelData.id;onClicked:page.turnTo(0,modelData.id)}}
        }
        RowLayout {
            Layout.fillWidth:true;visible:page.tab==="enemies" || page.tab==="weapons"
            ComboBox {objectName:"galleryOriginFilter";visible:page.tab==="enemies";model:["All","Hellborne","Space","Void"];Layout.preferredWidth:150;currentIndex:model.indexOf(page.enemyOrigin);onActivated:page.enemyOrigin=currentText}
            ComboBox {objectName:"galleryWeaponFilter";visible:page.tab==="weapons";model:["All","Guns","Staffs","Melee"];Layout.preferredWidth:150;currentIndex:model.indexOf(page.weaponClass);onActivated:page.weaponClass=currentText}
            ComboBox {visible:page.tab==="enemies";model:["All","Normal","Ascended","Nightmare","Overlord"];Layout.preferredWidth:150;onActivated:page.enemyTier=currentText}
            Item {Layout.fillWidth:true}
            ComboBox {objectName:"galleryStatsSort";model:page.tab==="enemies" ? ["Name","Kills","Deaths"] : ["Name","Kills"];onActivated:{if(page.tab==="enemies") page.enemySort=currentText;else page.weaponSort=currentText}}
        }
        Item {
            id:bookArea
            Layout.fillWidth:true;Layout.fillHeight:true
            ControlsReference {anchors.fill:parent;visible:page.tab==="controls"}
            Loader {anchors.fill:parent;active:page.tab==="kits";sourceComponent:KitGallery {}}
            Rectangle {
                id:binding
                visible:!["controls","kits"].includes(page.tab)
                anchors.centerIn:parent;width:Math.min(1180,parent.width-16);height:parent.height-8
                color:"#1a1016";border.color:"#503132";border.width:5;radius:8
                Rectangle {anchors.fill:parent;anchors.margins:9;color:"#6c4732";radius:4}
                Row {
                    anchors.fill:parent;anchors.margins:14;spacing:0
                    Repeater {
                        model:2
                        Rectangle {
                            required property int index
                            width:parent.width/2;height:parent.height;color:index ? "#dac398" : "#cdb58e"
                            gradient:Gradient {orientation:Gradient.Horizontal;GradientStop {position:0;color:index ? "#ad916c" : "#d8c29c"} GradientStop {position:.12;color:"#d8c29c"} GradientStop {position:.88;color:"#d8c29c"} GradientStop {position:1;color:index ? "#d0b589" : "#a98c68"}}
                            Canvas {
                                anchors.fill:parent
                                onPaint: {
                                    const c=getContext("2d");c.reset();c.fillStyle="#873030"
                                    for(let i=0;i<18;i++){const x=((i*97+index*23)%101)/101*width,y=i%2 ? height-((i*43)%65) : ((i*73)%37);c.globalAlpha=.18+i%4*.05;c.beginPath();c.ellipse(x,y,4+i%5*4,2+i%7*3);c.fill()}
                                    c.strokeStyle="#6e2827";c.lineWidth=2;c.globalAlpha=.23;c.beginPath();c.moveTo(width*.1,height*.95);c.bezierCurveTo(width*.4,height*.77,width*.15,height*.6,width*.25,height*.45);c.stroke()
                                }
                            }
                        }
                    }
                }
                RowLayout {
                    anchors.fill:parent;anchors.margins:28;spacing:24;opacity:1-page.flip*.45
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.fillHeight:true;Layout.preferredWidth:1;spacing:10
                        Text {text:page.tab.toUpperCase();color:"#70483a";font.family:"serif";font.letterSpacing:3;font.pixelSize:13;Layout.alignment:Qt.AlignHCenter}
                        Rectangle {
                            Layout.fillWidth:true;Layout.fillHeight:true;Layout.maximumHeight:440
                            color:"#ccb58e";border.color:page.tierColor;border.width:2;radius:2
                            Loader {anchors.fill:parent;anchors.margins:5;active:page.seen && !!page.entry;sourceComponent:page.tab==="achievements" ? medalArt : sketchArt}
                            Text {anchors.centerIn:parent;text:"?";visible:!page.seen;font.family:"serif";font.italic:true;font.pixelSize:Math.min(parent.width,parent.height)*.72;color:"#55413c";rotation:-9}
                        }
                        Text {
                            Layout.fillWidth:true;wrapMode:Text.WordWrap;horizontalAlignment:Text.AlignHCenter
                            text:!page.seen ? "Unrecorded" : page.tab==="enemies" ? page.entry.origin+" · "+Encounters.tier(page.entry.id)+" · first wave "+Encounters.firstWave(page.entry.id)
                                : page.tab==="weapons" ? Gear.weaponClass(page.entry)+" · "+Gear.rarities[page.entry.rarity].label : page.tab==="abilities" ? page.entry.category+(page.entry.rarity ? " · "+Gear.rarities[page.entry.rarity].label : "") : ""
                            color:page.seen && page.tab==="enemies" ? ({Hellborne:"#8c3028",Space:"#245b78",Void:"#694076"})[page.entry.origin] || "#713d32" : "#713d32";font.pixelSize:12;font.bold:true
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth:true;Layout.fillHeight:true;Layout.preferredWidth:1;spacing:12
                        Text {text:page.heading;color:page.ink;font.family:"serif";font.pixelSize:Math.min(30,page.width*.035);font.bold:true;Layout.fillWidth:true;wrapMode:Text.WordWrap}
                        Rectangle {height:2;Layout.fillWidth:true;color:"#8c4b3e";opacity:.6}
                        ScrollView {
                            Layout.fillWidth:true;Layout.fillHeight:true;contentWidth:availableWidth;clip:true
                            Text {width:parent.width;text:page.description || "";color:page.ink;font.family:"serif";font.pixelSize:page.width<900 ? 15 : 18;lineHeight:1.25;wrapMode:Text.WordWrap}
                        }
                        Text {visible:page.seen && ["enemies","weapons","achievements"].includes(page.tab);Layout.fillWidth:true;wrapMode:Text.WordWrap;color:"#713c35";font.family:"serif";font.pixelSize:13
                            text:!page.entry ? "" : page.tab==="enemies" ? "Slain: "+(page.career["enemyKills_"+page.entry.id]||0)+" · Deaths: "+(page.career["enemyDeaths_"+page.entry.id]||0)
                                : page.tab==="weapons" ? "Enemies killed with: "+(page.career["weaponKills_"+page.entry.id]||0)
                                : "Progress: "+Math.min(page.entry.target,page.career[page.entry.metric]||0)+" / "+page.entry.target+(page.achievementsUnlocked || Progress.complete(page.career,page.entry) ? " · UNLOCKED" : "")}
                        Text {Layout.alignment:Qt.AlignHCenter;text:(page.pageIndex+1)+" / "+page.displayed.length;color:"#775442";font.family:"serif";font.pixelSize:14}
                    }
                }
                Rectangle {
                    width:parent.width/2-14;height:parent.height-28;x:parent.width/2;y:14;visible:page.flip>0
                    color:"#ddc9a5";opacity:Math.sin(page.flip*Math.PI)
                    transform:Rotation {origin.x:0;origin.y:binding.height/2;axis {x:0;y:1;z:0}
                    angle:-180*page.flip}
                    Rectangle {anchors.top:parent.top;anchors.left:parent.left;width:parent.width*.4;height:2;color:"#a1443d"}
                }
                Rectangle {
                    id:cover
                    anchors.fill:parent;visible:page.opening<.999;color:"#151019";border.color:"#563236";border.width:7;radius:7;z:5
                    transform:Rotation {origin.x:0;origin.y:cover.height/2;axis {x:0;y:1;z:0}
                    angle:-145*page.opening}
                    Text {anchors.top:parent.top;anchors.topMargin:30;anchors.horizontalCenter:parent.horizontalCenter;text:"PROJECT BLACKBOX";font.family:"serif";font.pixelSize:25;font.letterSpacing:5;color:"#ad7d59"}
                    Canvas {anchors.centerIn:parent;width:Math.min(parent.width*.55,parent.height*.70);height:width
                        onPaint:{const c=getContext("2d");const r=width*.42;c.reset();c.translate(width/2,height/2);c.strokeStyle="#9b1e31";c.lineWidth=7;c.shadowColor="#be1e34";c.shadowBlur=14;c.beginPath();c.arc(0,0,r,0,6.283);c.stroke();c.beginPath();for(let i=0;i<=5;i++){let a=-Math.PI/2+i*Math.PI*.8;c.lineTo(Math.cos(a)*r,Math.sin(a)*r)}c.stroke();c.lineWidth=2;for(let i=0;i<8;i++){c.beginPath();c.moveTo((i-4)*r*.18,r*.5);c.lineTo((i-4)*r*.18,r*(.75+i%3*.22));c.stroke()}}}
                    Text {anchors.bottom:parent.bottom;anchors.bottomMargin:30;anchors.horizontalCenter:parent.horizontalCenter;text:"NAMES WRITTEN IN BLOOD";font.family:"serif";font.pixelSize:15;color:"#bd8f70";font.letterSpacing:3}
                }
            }
        }
        RowLayout {
            visible:!["controls","kits"].includes(page.tab);Layout.fillWidth:true
            ActionButton {objectName:"bookPrevious";text:"← Previous";enabled:page.pageIndex>0;onClicked:page.turnTo(page.pageIndex-1,"")}
            ComboBox {Layout.fillWidth:true;model:page.displayed.map(function(e){return page.tab==="enemies" && !page.revealAll && !page.known.enemies.includes(e.id) ? "Unknown" : e.title});currentIndex:page.pageIndex;onActivated:page.turnTo(currentIndex,"")}
            ActionButton {objectName:"bookNext";text:"Next →";enabled:page.pageIndex<page.displayed.length-1;onClicked:page.turnTo(page.pageIndex+1,"")}
        }
    }
    Component {id:sketchArt;GalleryPortrait {entry:page.entry;tint:page.tierColor;layer.enabled:GraphicsInfo.api!==GraphicsInfo.Software;layer.effect:ShaderEffect {fragmentShader:Qt.resolvedUrl("../shaders/pencil.frag.qsb")}}}
    Component {id:medalArt;Medal {medalId:page.entry.id;group:page.entry.group;metric:page.entry.metric;earned:page.achievementsUnlocked || Progress.complete(page.career,page.entry)}}
}

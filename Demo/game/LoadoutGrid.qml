import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

GridLayout {
    id: grid
    required property var run
    required property int revision
    property var groups: Object.keys(Gear.limits)
    property string offerId: ""
    property bool animate: true
    property bool compact: false
    property bool dense: false
    property bool editable: true
    property int inventorySelection: -1
    readonly property var incoming: { revision; return inventorySelection >= 0 ? run.inventory[inventorySelection] : null }
    signal entryRequested(string chapter, string id)
    signal inventoryPlaced(int cell, string group, int slot)
    property string selectedGroup: ""
    property int selectedIndex: -1
    signal swapped(string group, int from, int to)
    signal placed(string offerId, int slot)
    property bool shrineLayout:false
    readonly property bool narrow:dense || width<720
    columns:shrineLayout ? 3 : Math.max(1,groups.length)
    columnSpacing:shrineLayout ? 9 : 6
    rowSpacing:7

    Ui.ShrineFrame {
        id:portrait
        visible:grid.shrineLayout
        Layout.row:0
        Layout.column:1
        Layout.rowSpan:2
        Layout.fillHeight:true
        Layout.fillWidth:true
        Layout.minimumWidth:grid.narrow ? 94 : 142
        Layout.preferredWidth:grid.narrow ? 128 : 216
        fill:Ui.InterfaceTheme.current.surface
        tone:Ui.InterfaceTheme.current.line
        Item {
            anchors.fill:parent
            anchors.margins:7
            Rectangle {
                anchors.top:parent.top
                anchors.topMargin:6
                anchors.horizontalCenter:parent.horizontalCenter
                width:Math.min(parent.width-5,170)
                height:Math.min(parent.height-36,width*1.05)
                radius:Ui.InterfaceTheme.current.shape==="arch" ? width*.47 : Ui.InterfaceTheme.current.shape==="scope" ? width*.5 : 8
                color:Ui.InterfaceTheme.current.base
                border.color:Qt.darker(Ui.InterfaceTheme.current.line,1.5)
                Image {
                    anchors.fill:parent
                    anchors.margins:5
                    source:"../assets/landscape/expeditioner.png"
                    fillMode:Image.PreserveAspectFit
                    smooth:true
                    Accessible.name:"Expeditioner portrait"
                }
            }
            Text {
                anchors.bottom:parent.bottom
                anchors.bottomMargin:5
                width:parent.width
                horizontalAlignment:Text.AlignHCenter
                text:"Expeditioner"
                color:Ui.InterfaceTheme.text
                font.family:Ui.InterfaceTheme.heading
                font.pixelSize:Ui.UiMetrics.text(grid.narrow ? 12 : 16)
                elide:Text.ElideRight
            }
        }
    }

    function clearSelection() {
        selectedGroup = ""
        selectedIndex = -1
    }

    function select(group, index) {
        if (!editable)
            return
        if (inventorySelection >= 0) {
            inventoryPlaced(inventorySelection, group, index)
            return
        }
        if (offerId.length) {
            placed(offerId, index)
            return
        }
        if (selectedGroup !== group || selectedIndex === -1) {
            if (run.slots[group][index].item) {
                selectedGroup = group
                selectedIndex = index
            }
            return
        }
        const source = selectedIndex
        selectedIndex = -1
        selectedGroup = ""
        if (source !== index)
            swapped(group, source, index)
    }

    Repeater {
        model: grid.groups
        delegate: Item {
            id: track
            required property string modelData
            required property int index
            readonly property string group: modelData
            readonly property bool weaponTrack:grid.shrineLayout && group==="weapon"
            Layout.row:grid.shrineLayout && group==="passive" ? 1 : 0
            Layout.column:grid.shrineLayout ? (weaponTrack ? 0 : 2) : index
            Layout.rowSpan:weaponTrack ? 2 : 1
            Layout.fillWidth:grid.shrineLayout || grid.groups.length===1
            Layout.fillHeight:weaponTrack
            Layout.minimumWidth:grid.shrineLayout ? (weaponTrack ? 118 : 184) : 0
            Layout.preferredWidth:grid.shrineLayout ? (weaponTrack ? 249 : 390) : rack.implicitWidth
            implicitWidth:rack.implicitWidth
            implicitHeight:rack.implicitHeight+(grid.shrineLayout ? 14 : 0)
            Ui.ShrineFrame {
                anchors.fill:parent
                visible:grid.shrineLayout
                fill:Ui.InterfaceTheme.current.surface
                tone:Ui.InterfaceTheme.group(track.group)
            }
            ColumnLayout {
                id:rack
                anchors.fill:parent
                anchors.margins:grid.shrineLayout ? 7 : 0
                spacing:grid.shrineLayout ? 6 : 5

                Text {
                    Layout.fillWidth:true
                    text:grid.shrineLayout ? ({weapon:"Weapons",active:"Actives",passive:"Passives"})[track.group] : Gear.groupLabels[track.group]
                    color:Ui.InterfaceTheme.group(track.group)
                    font.family:grid.shrineLayout ? Ui.InterfaceTheme.heading : "IBM Plex Mono"
                    font.bold:grid.shrineLayout
                    font.pixelSize:Ui.UiMetrics.text(grid.shrineLayout && !grid.narrow ? 16 : 12)
                    elide:Text.ElideRight
                }
                GridLayout {
                    Layout.fillWidth:grid.shrineLayout
                    Layout.fillHeight:track.weaponTrack
                    columns:track.weaponTrack ? 1 : Math.min(4,Gear.limits[track.group])
                    rowSpacing:track.weaponTrack ? 7 : 4
                    columnSpacing:4
                    uniformCellWidths:true
                    uniformCellHeights:true
                Repeater {
                    model: Gear.limits[track.group]
                    delegate: Ui.ActionButton {
                        id: slotTile
                        required property int index
                        readonly property var slot: { grid.revision; return grid.run.slots[track.group][index] || null }
                        readonly property var item: { grid.revision; return slot ? slot.item : null }
                        readonly property bool transferTarget: grid.inventorySelection >= 0 && slot !== null
                            && (grid.incoming ? grid.incoming.group === track.group : !!item)
                        readonly property var spec: item ? Gear.catalogs[track.group][item.id] : null
                        readonly property bool showsPortrait: !!spec && !grid.offerId.length
                        readonly property var power: { grid.revision; return Gear.slotPower(track.group, slot) }
                        readonly property bool powerLive: { grid.revision; return !!Gear.socketEffect(grid.run,track.group,slot).id }
                        readonly property color upgradeColor: { grid.revision; return Gear.slotUpgradeColor(track.group, slot) }
                        readonly property string number: track.group === "active" ? (index === 0 ? "Q" : "E") : String(index + 1)
                        readonly property color tierColor: spec ? Gear.rarities[spec.rarity].color : "#77728b"
                        objectName: grid.offerId.length ? "replaceSlot-" + index : "swap-" + track.group + "-" + index
                        Layout.preferredWidth: grid.shrineLayout ? (track.weaponTrack ? 132 : 75) : 86
                        Layout.minimumWidth: grid.shrineLayout ? (track.weaponTrack ? 95 : 39) : 53
                        Layout.fillWidth: true
                        Layout.fillHeight:track.weaponTrack
                        Layout.maximumWidth: grid.shrineLayout ? 1000 : grid.dense ? 62 : grid.compact ? 72 : 84
                        Layout.minimumHeight:grid.shrineLayout && track.weaponTrack ? 53 : 0
                        Layout.preferredHeight:grid.shrineLayout ? (track.weaponTrack ? 67 : grid.narrow ? 39 : 54) : width
                        z: sourceDrag.dragging ? 10 : 0
                        enabled: slot !== null && (!grid.incoming || grid.incoming.group === track.group)
                        leftPadding: 6
                        rightPadding: 6
                        topPadding: 5
                        bottomPadding: 10
                        text:spec ? spec.title : ""
                        primary: grid.selectedGroup === track.group && grid.selectedIndex === index
                        accent: tierColor
                        Accessible.name:Gear.groupLabels[track.group]+" "+number+", "+(spec ? text : slot ? "empty" : "locked")
                        Accessible.description: (sourceDrag.available ? "Drag to move. " : !grid.editable && item ? "Read only. " : "") + (grid.offerId.length && spec ? "Replace " + spec.title + ". " : "")
                            + (power.title ? power.title + ". " + power.description : "")
                        hintEnabled: hovered && (!!spec || !!power.title)
                        hintStats: hovered && track.group==="weapon" && item && item!==Gear.current(grid.run)
                            ? Gear.weaponComparison(grid.run,Gear.current(grid.run),item) : []
                        hintDelay: 420
                        entryChapter:spec ? (track.group==="weapon" ? "weapons" : "abilities") : "shop"
                        entryId:spec ? (spec.debugOnly ? "" : spec.id) : power.id || ""
                        onEntryRequested:function(chapter,id) { grid.entryRequested(chapter,id) }
                        hintText:{
                            grid.revision
                            return (grid.offerId.length && spec ? "Replace " : "") + text
                            + (power.title ? "\nSlot effect · " + power.title + " · Lv " + power.level + "\n" + power.description
                                +(powerLive ? "\nActive with this build." : "\nWaiting for a compatible build.") : "")
                                + (spec ? "\n" + Gear.itemDetails(grid.run,track.group,item) : "")
                        }
                        onClicked: grid.select(track.group, index)
                        contentItem: Item {
                            Loader {
                                id:gearPortrait
                                active:slotTile.showsPortrait
                                anchors.left:parent.left
                                anchors.top:parent.top
                                anchors.bottom:parent.bottom
                                width:track.weaponTrack ? Math.min(parent.width*.38,89) : parent.width
                                opacity:grid.shrineLayout && !track.weaponTrack ? .74 : 1
                                sourceComponent:Ui.GalleryPortrait {
                                    entry:slotTile.spec
                                    tint:slotTile.tierColor
                                    border.color:"transparent"
                                    color:"transparent"
                                }
                            }
                            Text {
                                visible:!!slotTile.item
                                anchors.left:parent.left
                                anchors.top:parent.top
                                width:parent.width
                                color:slotTile.primary ? "#191423" : slotTile.tierColor
                                text:{grid.revision;return slotTile.number+(slotTile.item ? " · Lv "+slotTile.item.level : "")}
                                font.family:"IBM Plex Mono"
                                font.pixelSize:Ui.UiMetrics.text(10)
                                elide:Text.ElideRight
                            }
                            Text {
                                anchors.left:track.weaponTrack && slotTile.showsPortrait ? gearPortrait.right : parent.left
                                anchors.leftMargin:track.weaponTrack && slotTile.showsPortrait ? 6 : 0
                                anchors.right:parent.right
                                anchors.rightMargin:sourceDrag.available ? 19 : 0
                                anchors.bottom:grid.shrineLayout && !track.weaponTrack && slotTile.showsPortrait ? parent.bottom : undefined
                                anchors.verticalCenter:grid.shrineLayout && !track.weaponTrack && slotTile.showsPortrait ? undefined : parent.verticalCenter
                                visible:grid.shrineLayout || !slotTile.showsPortrait
                                text:slotTile.text
                                color:slotTile.primary ? "#191423" : Ui.InterfaceTheme.text
                                font.family:"Inter"
                                font.bold:track.weaponTrack && !!slotTile.spec
                                font.pixelSize:Ui.UiMetrics.text(grid.shrineLayout && !track.weaponTrack ? (track.group==="active" ? 12 : 11) : 12)
                                elide:Text.ElideRight
                                style:slotTile.showsPortrait && !track.weaponTrack && !slotTile.primary ? Text.Outline : Text.Normal
                                styleColor:"#22121f"
                            }
                            Text {
                                visible:!!slotTile.power.title && (track.weaponTrack || !slotTile.showsPortrait)
                                anchors.left:parent.left
                                anchors.right:parent.right
                                anchors.bottom:parent.bottom
                                text:slotTile.power.title || ""
                                elide:Text.ElideRight
                                color:slotTile.primary ? "#191423" : slotTile.upgradeColor
                                font.family:"Inter"
                                font.pixelSize:Ui.UiMetrics.text(9)
                            }
                        }
                        background: Rectangle {
                            radius: Ui.InterfaceTheme.current.radius*.7
                            color: slotTile.primary ? slotTile.tierColor : drop.containsDrag || slotTile.transferTarget ? "#354862"
                                : slotTile.hovered ? Ui.InterfaceTheme.current.hover : Ui.InterfaceTheme.current.slot
                            border.color: slotTile.visualFocus || drop.containsDrag ? "#fffaef"
                                : slotTile.transferTarget ? "#8bf1e0" : slotTile.tierColor
                            Behavior on color { ColorAnimation { duration: grid.animate ? 125 : 0 } }
                        }
                        Ui.ChainedLock {visible:!slotTile.slot}
                        UpgradeRim {
                            anchors.fill: parent
                            tint: slotTile.upgradeColor
                            motion: grid.animate
                            socketRank:slotTile.power.id ? slotTile.power.level : -1
                            socketReady:!slotTile.power.id || slotTile.powerLive
                        }
                        GearDrag {
                            id: sourceDrag
                            objectName: "slotGrip-" + track.group + "-" + slotTile.index
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 3
                            width: 19
                            height: 19
                            showGrip: true
                            group: track.group
                            title: slotTile.text
                            fromIndex: slotTile.index
                            available: grid.editable && !!slotTile.item && !grid.offerId.length
                        }
                        DropArea {
                            id: drop
                            anchors.fill: parent
                            enabled: grid.editable && slotTile.slot !== null
                            keys: [track.group, "bag-" + track.group]
                            onDropped: function(event) {
                                const source = event.source as GearDrag
                                if (!slotTile.slot || !source)
                                    return
                                if (source.bagCell >= 0 && source.group === track.group && !grid.offerId.length) {
                                    event.accept()
                                    grid.inventoryPlaced(source.bagCell, track.group, slotTile.index)
                                } else if (grid.offerId.length && source.offerId === grid.offerId) {
                                    event.accept()
                                    grid.placed(source.offerId, slotTile.index)
                                } else if (!grid.offerId.length && source.fromIndex >= 0 && source.fromIndex !== slotTile.index) {
                                    event.accept()
                                    grid.selectedIndex = -1
                                    grid.selectedGroup = ""
                                    grid.swapped(track.group, source.fromIndex, slotTile.index)
                                }
                            }
                        }
                    }
                }
            }
            }
        }
    }
}

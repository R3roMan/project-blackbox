import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

ColumnLayout {
    id: inventory
    objectName: "inventoryPanel"
    required property var run
    required property int revision
    required property bool animate
    property bool dense: false
    property bool editable: true
    property int selectedCell: -1
    property string transferMessage: ""
    readonly property var selectedItem: { revision; return selectedCell >= 0 ? run.inventory[selectedCell] : null }
    signal entryRequested(string chapter, string id)
    signal moved(int cell, string group, int slot)
    signal swapped(string group, int from, int to)
    spacing: dense ? 6 : 8

    function move(cell, group, slot) {
        if (!editable)
            return
        const from = run.inventory[cell]
        if (!from || from.group === group) {
            const wearing = run.slots[group][slot].item
            inventory.moved(cell, group, slot)
            if (run.slots[group][slot].item !== wearing) {
                const current = run.slots[group][slot].item
                transferMessage = current ? "Equipped " + Gear.catalogs[group][current.id].title
                    : "Stored " + Gear.catalogs[group][wearing.id].title
            } else if (group === "weapon" && wearing && !from) {
                transferMessage = "Keep one weapon equipped."
            }
            selectedCell = -1
            equipped.clearSelection()
        }
    }

    LoadoutGrid {
        id: equipped
        Layout.fillWidth: true
        run: inventory.run
        revision: inventory.revision
        shrineLayout:true
        compact: true
        dense: inventory.dense
        animate: inventory.animate
        editable: inventory.editable
        inventorySelection: inventory.selectedCell
        onEntryRequested:function(chapter,id) { inventory.entryRequested(chapter,id) }
        onInventoryPlaced: function(cell, group, slot) { inventory.move(cell, group, slot) }
        onSwapped: function(group, from, to) { inventory.swapped(group, from, to) }
    }
    Ui.ShrineFrame {
        Layout.fillWidth:true
        fill:Ui.InterfaceTheme.current.surface
        tone:Ui.InterfaceTheme.inventory
        implicitHeight:bagLayout.implicitHeight+16
        ColumnLayout {
            id:bagLayout
            anchors.fill:parent
            anchors.margins:8
            spacing:6
            RowLayout {
                Layout.fillWidth:true
                Text {
                    Layout.fillWidth:true
                    text:"Inventory"
                    font.family:Ui.InterfaceTheme.heading
                    font.pixelSize:Ui.UiMetrics.text(16)
                    font.bold:true
                    color:Ui.InterfaceTheme.inventory
                }
                Text {
                    text:{inventory.revision;return inventory.run.inventory.filter(Boolean).length+" / "+inventory.run.inventory.length}
                    font.family:"IBM Plex Mono"
                    font.pixelSize:Ui.UiMetrics.text(11)
                    color:Ui.InterfaceTheme.inventory
                }
            }
    GridLayout {
        Layout.fillWidth:true
        columns:Math.min(inventory.run.inventory.length,Math.max(3,Math.floor((inventory.width-16)/(inventory.dense ? 66 : 82))))
        uniformCellWidths:true
        uniformCellHeights:true
        columnSpacing:5
        rowSpacing:5
        Repeater {
            model: { inventory.revision; return inventory.run.inventory.length }
            Ui.ActionButton {
                id: storage
                required property int index
                readonly property var entry: { inventory.revision; return inventory.run.inventory[index] }
                readonly property var spec: entry ? Gear.catalogs[entry.group][entry.item.id] : null
                objectName: "inventory-cell-" + index
                text:spec ? spec.title : ""
                Layout.fillWidth: true
                Layout.preferredWidth:90
                Layout.minimumWidth:45
                Layout.preferredHeight:inventory.dense ? 43 : 51
                leftPadding: 6
                rightPadding: 6
                topPadding: 5
                bottomPadding: 10
                primary: inventory.selectedCell === index
                accent: spec ? Gear.rarities[spec.rarity].color : "#9d90ac"
                Accessible.name:"Inventory "+(index+1)+", "+(spec ? text : "empty")
                Accessible.description: !inventory.editable && spec ? "Read only during combat." : dragGear.available ? "Drag to move." : ""
                hintEnabled: hovered && !!spec
                hintDelay: 420
                entryChapter:entry?.group==="weapon" ? "weapons" : "abilities"
                entryId:spec?.id && !spec.debugOnly ? spec.id : ""
                onEntryRequested:function(chapter,id) { inventory.entryRequested(chapter,id) }
                hintStats: hovered && entry && entry.group==="weapon"
                    ? Gear.weaponComparison(inventory.run,Gear.current(inventory.run),entry.item) : []
                hintText:{
                    inventory.revision
                    return storage.spec ? storage.text+" · "+Gear.groupLabels[storage.entry.group]
                        +"\n"+Gear.itemDetails(inventory.run,storage.entry.group,storage.entry.item) : ""
                }
                z: dragGear.dragging ? 10 : 0
                onClicked: {
                    if (!inventory.editable)
                        return
                    if (equipped.selectedIndex >= 0) {
                        inventory.move(index, equipped.selectedGroup, equipped.selectedIndex)
                    } else {
                        inventory.transferMessage = ""
                        inventory.selectedCell = inventory.selectedCell === index ? -1 : index
                    }
                }
                contentItem: ColumnLayout {
                    spacing: 2
                    Text {
                        visible:!!storage.entry
                        text:{inventory.revision;return storage.entry ? "Lv "+storage.entry.item.level : ""}
                        color: storage.primary ? "#211827" : storage.accent
                        font.family: "IBM Plex Mono"
                        font.pixelSize: Ui.UiMetrics.text(10)
                    }
                    Loader {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        visible: active
                        active: !!storage.spec
                        sourceComponent: Ui.GalleryPortrait {
                            entry: storage.spec
                            tint: storage.accent
                            color: "#39161925"
                            border.color: "transparent"
                        }
                    }
                }
                background: Rectangle {
                    radius: Ui.InterfaceTheme.current.radius*.7
                    color: storage.primary ? storage.accent : storageDrop.containsDrag ? "#354862"
                        : storage.hovered ? Ui.InterfaceTheme.current.hover : Ui.InterfaceTheme.current.slot
                    border.color: storage.visualFocus || storageDrop.containsDrag ? "#fffaef" : storage.accent
                    Rectangle {
                        visible: !!storage.spec && !storage.primary
                        x: 1
                        y: 5
                        width: 2
                        height: parent.height - 10
                        radius: 1
                        color: storage.accent
                    }
                    Behavior on color { ColorAnimation { duration: inventory.animate ? 125 : 0 } }
                }
                UpgradeRim {
                    anchors.fill: parent
                    tint: {
                        inventory.revision
                        return storage.entry ? Gear.slotUpgradeColor(storage.entry.group, storage.entry) : "transparent"
                    }
                    motion: inventory.animate
                }
                GearDrag {
                    id: dragGear
                    objectName: "inventoryGrip-" + storage.index
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 3
                    width:19
                    height:19
                    showGrip: true
                    group: storage.entry ? storage.entry.group : ""
                    title: storage.text
                    bagCell: storage.index
                    available: inventory.editable && !!storage.entry
                }
                DropArea {
                    id: storageDrop
                    anchors.fill: parent
                    enabled: inventory.editable
                    keys: storage.entry ? [storage.entry.group] : Object.keys(Gear.limits)
                    onDropped: function(event) {
                        const source = event.source as GearDrag
                        if (source && source.fromIndex >= 0 && (!storage.entry || storage.entry.group === source.group)) {
                            event.accept()
                            inventory.move(storage.index, source.group, source.fromIndex)
                        }
                    }
                }
            }
        }
    }
        }
    }
    Text {
        Layout.fillWidth: true
        text: {
            if (!inventory.editable)
                return "Loadout edits open between waves."
            if (inventory.selectedItem) {
                const item = inventory.selectedItem
                return Gear.catalogs[item.group][item.item.id].title + " · Lv " + item.item.level
                    + " · Choose a " + Gear.groupLabels[item.group].toLowerCase() + " slot."
            }
            if (inventory.selectedCell >= 0)
                return "Choose equipped gear to store here."
            if (equipped.selectedIndex >= 0)
                return "Choose a storage square to move this item."
            return inventory.transferMessage || "Use the dotted grip to drag gear, or select two slots."
        }
        color: inventory.selectedCell >= 0 || equipped.selectedIndex >= 0 ? "#9deee4" : "#d7c6d9"
        font.family: "Inter"
        font.pixelSize: Ui.UiMetrics.text(14)
        wrapMode: Text.WordWrap
    }
}

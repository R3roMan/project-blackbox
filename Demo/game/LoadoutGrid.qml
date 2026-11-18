import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

RowLayout {
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
    spacing: 10

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
        delegate: ColumnLayout {
            id: track
            required property string modelData
            readonly property string group: modelData
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            spacing: 5
            Text {
                text: Gear.groupLabels[track.group]
                color: "#d7c5d7"
                font.family: "IBM Plex Mono"
                font.pixelSize: Ui.UiMetrics.text(12)
            }
            GridLayout {
                columns: Math.min(4, Gear.limits[track.group])
                rowSpacing: 4
                columnSpacing: 4
                uniformCellWidths: true
                uniformCellHeights: true
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
                        Layout.preferredWidth: 86
                        Layout.minimumWidth: 53
                        Layout.fillWidth: true
                        Layout.maximumWidth: grid.dense ? 62 : grid.compact ? 72 : 84
                        Layout.preferredHeight: width
                        z: sourceDrag.dragging ? 10 : 0
                        enabled: slot !== null && (!grid.incoming || grid.incoming.group === track.group)
                        leftPadding: 6
                        rightPadding: 6
                        topPadding: 5
                        bottomPadding: 10
                        text: (spec ? spec.title : slot ? "Empty" : "Locked")
                        primary: grid.selectedGroup === track.group && grid.selectedIndex === index
                        accent: tierColor
                        Accessible.name: Gear.groupLabels[track.group] + " " + number + ", " + text
                        Accessible.description: (grid.offerId.length && spec ? "Replace " + spec.title + ". " : "")
                            + (power.title ? power.title + ". " + power.description : "")
                        hintEnabled: hovered && (!!spec || !!power.title)
                        hintDelay: 420
                        entryChapter:spec ? (track.group==="weapon" ? "weapons" : "abilities") : "shop"
                        entryId:spec ? (spec.debugOnly ? "" : spec.id) : power.id || ""
                        onEntryRequested:function(chapter,id) { grid.entryRequested(chapter,id) }
                        hintText: (grid.offerId.length && spec ? "Replace " : "") + text
                            + (power.title ? "\nSlot effect · " + power.title + " · Lv " + power.level + "\n" + power.description
                                +(powerLive ? "\nActive with this build." : "\nWaiting for a compatible build.") : "")
                            + (spec ? "\n" + Gear.itemDetails(grid.run,track.group,item) : "")
                        onClicked: grid.select(track.group, index)
                        contentItem: ColumnLayout {
                            spacing: 2
                            Text {
                                Layout.fillWidth: true
                                color: slotTile.primary ? "#191423" : slotTile.tierColor
                                text: { grid.revision; return slotTile.number + (slotTile.item ? " · Lv " + slotTile.item.level : "") }
                                font.family: "IBM Plex Mono"
                                font.pixelSize: Ui.UiMetrics.text(10)
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                visible: !slotTile.showsPortrait
                                verticalAlignment: Text.AlignVCenter
                                text: slotTile.text
                                color: slotTile.primary ? "#191423" : "#f0e3ec"
                                wrapMode: Text.Wrap
                                elide: Text.ElideRight
                                font.family: "Inter"
                                font.pixelSize: Ui.UiMetrics.text(12)
                            }
                            Loader {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Layout.minimumHeight: 25
                                visible: active
                                active: slotTile.showsPortrait
                                sourceComponent: Ui.GalleryPortrait {
                                    entry: slotTile.spec
                                    tint: slotTile.tierColor
                                    border.color: "transparent"
                                    color: "#34141723"
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: !!slotTile.power.title
                                text: slotTile.power.title || ""
                                elide: Text.ElideRight
                                color: slotTile.primary ? "#191423" : slotTile.upgradeColor
                                font.family: "Inter"
                                font.pixelSize: Ui.UiMetrics.text(9)
                            }
                        }
                        background: Rectangle {
                            radius: 6
                            color: slotTile.primary ? slotTile.tierColor : drop.containsDrag || slotTile.transferTarget ? "#354862"
                                : slotTile.hovered ? "#302c3d" : "#201e2b"
                            border.color: slotTile.visualFocus || drop.containsDrag ? "#fffaef"
                                : slotTile.transferTarget ? "#8bf1e0" : slotTile.tierColor
                            Behavior on color { ColorAnimation { duration: grid.animate ? 125 : 0 } }
                        }
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
                            width: 17
                            height: 16
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

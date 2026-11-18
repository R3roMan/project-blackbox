pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

ColumnLayout {
    id: menu
    required property var run
    required property int revision
    signal equipRequested(string group, string id, int slot)
    property string group: "weapon"
    readonly property var items: Object.values(Gear.catalogs[group]).filter(function(card) { return !card.debugOnly })
        .sort(function(first, second) { return first.title.localeCompare(second.title) })
    readonly property var item: items[gearPicker.currentIndex] || items[0]
    spacing: 9

    RowLayout {
        spacing: 5
        Repeater {
            model: Object.keys(Gear.groupLabels)
            Ui.ActionButton {
                required property string modelData
                objectName: "debugGroup-" + modelData
                text: Gear.groupLabels[modelData]
                primary: menu.group === modelData
                onClicked: {
                    menu.group = modelData
                    gearPicker.currentIndex = 0
                    slotPicker.currentIndex = 0
                }
            }
        }
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: 7
        ComboBox {
            id: gearPicker
            objectName: "debugGearChoice"
            Layout.fillWidth: true
            model: menu.items
            textRole: "title"
            valueRole: "id"
            Accessible.name: "Gear to equip"
        }
        ComboBox {
            id: slotPicker
            objectName: "debugSlotChoice"
            model: {
                menu.revision
                return menu.run.slots[menu.group].map(function(slot, index) { return "Slot " + (index + 1) })
            }
            Accessible.name: "Equipment destination"
        }
        Ui.ActionButton {
            objectName: "equipDebugGear"
            text: "Equip"
            primary: true
            onClicked: menu.equipRequested(menu.group, menu.item.id, slotPicker.currentIndex)
        }
    }
    Text {
        Layout.fillWidth: true
        text: menu.item.description
        color: "#e9ddec"
        font.family: "Inter"
        font.pixelSize: 13
        wrapMode: Text.WordWrap
    }
}

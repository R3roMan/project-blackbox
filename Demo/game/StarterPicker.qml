import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Loadout.js" as Gear

ColumnLayout {
    id: picker
    objectName: "starterPicker"
    required property var weapons
    required property string selectedId
    signal entryRequested(string chapter, string id)
    signal weaponSelected(string id)
    spacing: 5

    Text {
        text: "CHOOSE ONE STARTING WEAPON"
        color: "#f7be93"
        font.family: "IBM Plex Mono"
        font.pixelSize: 11
    }
    RowLayout {
        Layout.fillWidth: true
        uniformCellSizes: true
        spacing: 7

        Repeater {
            model: picker.weapons
            Ui.ActionButton {
                id: pick
                required property var modelData
                objectName: "starter-" + modelData.id
                Layout.fillWidth: true
                implicitHeight: 42
                leftPadding: 7
                rightPadding: 7
                topPadding: 5
                bottomPadding: 5
                primary: picker.selectedId === modelData.id
                accent: Gear.rarities[modelData.rarity].color
                text: modelData.title
                Accessible.description: modelData.description
                hintEnabled: hovered
                hintDelay: 360
                entryChapter:"weapons"
                entryId:modelData.id
                onEntryRequested:function(chapter,id) { picker.entryRequested(chapter,id) }
                hintText: modelData.title + "\n" + Gear.itemDetails(null,"weapon",{id:modelData.id,level:0})
                onClicked: picker.weaponSelected(modelData.id)

                contentItem: RowLayout {
                    spacing: 5
                    Ui.GalleryPortrait {
                        Layout.preferredWidth: 40
                        Layout.preferredHeight: 27
                        entry: pick.modelData
                        tint: pick.accent
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
                            text: pick.text
                            color: pick.primary ? "#181423" : "#f4e6ec"
                            elide: Text.ElideRight
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.DemiBold
                        }
                        Text {
                            text: Gear.rarities[pick.modelData.rarity].label
                            color: pick.primary ? "#302737" : pick.accent
                            font.family: "IBM Plex Mono"
                            font.pixelSize: 9
                        }
                    }
                }
            }
        }
    }
}

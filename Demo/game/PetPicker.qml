import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../ui" as Ui
import "Pets.js" as Pets

ColumnLayout {
    id: picker
    objectName: "petPicker"
    required property var availablePets
    required property string selectedId
    signal petSelected(string id)
    readonly property var selected: selectedId.length ? Pets.spec(selectedId) : null
    spacing: 6

    Text {
        text: "CHOOSE ONE COMPANION"
        color: Pets.uniqueColor
        font.family: "IBM Plex Mono"
        font.pixelSize: Ui.UiMetrics.text(12)
    }

    RowLayout {
        Layout.fillWidth: true
        uniformCellSizes: true
        spacing: 7
        Repeater {
            model: picker.availablePets
            Ui.ActionButton {
                id:offer
                required property var modelData
                objectName: "pet-" + modelData.id
                Layout.fillWidth: true
                text: modelData.title
                primary: picker.selectedId === modelData.id
                accent: Pets.uniqueColor
                Accessible.description: modelData.description
                hintEnabled: hovered
                hintDelay: 420
                hintText: modelData.title + "\n" + modelData.description
                contentItem:RowLayout {
                    spacing:5
                    ProjectedPet {
                        Layout.preferredWidth:36
                        Layout.preferredHeight:25
                        helper:offer.modelData
                        flap:.12
                    }
                    Text {
                        Layout.fillWidth:true
                        text:offer.text
                        font:offer.font
                        color:offer.primary ? "#181928" : "#f5e7ef"
                        elide:Text.ElideRight
                    }
                }
                onClicked: picker.petSelected(modelData.id)
            }
        }
    }
    Text {
        Layout.fillWidth: true
        text: picker.selected ? picker.selected.description + "  ·  " + picker.selected.duty + "s active / "
            + picker.selected.rest + "s rest" : ""
        wrapMode: Text.WordWrap
        color: "#d2dee5"
        font.family: "Inter"
        font.pixelSize: Ui.UiMetrics.text(14)
    }
}

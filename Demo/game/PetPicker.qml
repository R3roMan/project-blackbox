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
        font.pixelSize: 11
    }

    RowLayout {
        Layout.fillWidth: true
        uniformCellSizes: true
        spacing: 7
        Repeater {
            model: picker.availablePets
            Ui.ActionButton {
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
        font.pixelSize: 13
    }
}

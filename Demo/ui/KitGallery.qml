import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Loadout.js" as Gear

ColumnLayout {
    id: gallery
    property string query: ""

    TextField {
        objectName: "kitSearch"
        Layout.fillWidth: true
        placeholderText: "Find a kit, weapon or ability"
        font.family: "Inter"
        color: "#eadfee"
        placeholderTextColor: "#a9a3b7"
        leftPadding: 12
        background: Rectangle { color: "#232030"; border.color: "#665570"; radius: 5 }
        onTextChanged: gallery.query = text.trim().toLowerCase()
    }

    ListView {
        id: list
        objectName: "kitList"
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        spacing: 10
        reuseItems: true
        model: Gear.kits.filter(function(kit) {
            return [kit.title, Gear.weapons[kit.weapon].title, Gear.passives[kit.passive].title,
                Gear.activeAbilities[kit.active].title].join(" ").toLowerCase().includes(gallery.query)
        })
        ScrollBar.vertical: ScrollBar { }
        delegate: Rectangle {
            id: row
            required property var modelData
            objectName: "kit-" + (modelData.key || modelData.weapon)
            width: list.width - 15
            height: build.implicitHeight + 23
            color: "#242436"
            border.color: "#596686"
            radius: 6

            ColumnLayout {
                id: build
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 11
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: row.modelData.title
                    font.family: "Inter"
                    font.pixelSize: 17
                    font.weight: Font.Bold
                    color: "#fff1dd"
                }
                RowLayout {
                    Layout.fillWidth: true
                    uniformCellSizes: true
                    spacing: 8
                    Repeater {
                        model: [
                            Gear.weapons[row.modelData.weapon],
                            Gear.passives[row.modelData.passive],
                            Gear.activeAbilities[row.modelData.active]
                        ]
                        delegate: RowLayout {
                            id: member
                            required property var modelData
                            Layout.fillWidth: true
                            readonly property color tone: Gear.rarities[modelData.rarity].color
                            HoverHandler { id: hover }
                            ToolTip.visible: hover.hovered
                            ToolTip.delay: 420
                            ToolTip.text: modelData.title + "\n" + modelData.description
                            GalleryPortrait {
                                Layout.preferredWidth: 45
                                Layout.preferredHeight: 39
                                entry: member.modelData
                                tint: member.tone
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: member.modelData.title
                                    color: "#f0eaf2"
                                    font.family: "Inter"
                                    font.pixelSize: 12
                                    wrapMode: Text.WordWrap
                                }
                                Text {
                                    text: member.modelData.category
                                    color: member.tone
                                    font.family: "IBM Plex Mono"
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    text: row.modelData.bonus
                    color: "#e8c899"
                    wrapMode: Text.WordWrap
                    font.family: "Inter"
                    font.pixelSize: 12
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../game/Progress.js" as Progress
import "../game/Loadout.js" as Gear
import "../game/Pets.js" as Pets

Rectangle {
    id: page
    objectName: "achievementsPage"
    required property var profile
    property bool achievementsUnlocked: false
    signal closeRequested()
    signal unlockToggleRequested()
    color: "#111622"

    property var selected: Progress.achievements[0]
    readonly property int completed: Progress.unlocked(profile,achievementsUnlocked).length
    readonly property bool compact: height < 610

    function reward(item) {
        return item.group === "pet" ? Pets.spec(item.reward) : Gear.catalogs[item.group][item.reward]
    }

    function progress(item) {
        return achievementsUnlocked ? item.target : Math.max(0, Math.min(item.target, Number(profile[item.metric]) || 0))
    }

    Shortcut { sequence: "Escape"; onActivated: page.closeRequested() }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: page.compact ? 13 : 22
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: 8
            color: "#20283a"
            border.color: "#485978"
            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                ActionButton { text: "← Home"; onClicked: page.closeRequested() }
                Text {
                    Layout.fillWidth: true
                    text: "Achievements"
                    color: "#e8eefc"
                    font.family: "Inter"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    elide: Text.ElideRight
                }
                ActionButton {
                    objectName: "unlockAchievements"
                    text: page.achievementsUnlocked ? "Restore earned unlocks" : "Unlock all achievements"
                    primary: page.achievementsUnlocked
                    onClicked: page.unlockToggleRequested()
                }
                ColumnLayout {
                    spacing: 4
                    Text {
                        text: page.completed + " / " + Progress.achievements.length + " unlocked"
                        color: "#92efd7"
                        font.family: "IBM Plex Mono"
                        font.pixelSize: 13
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: "#39465d"
                        Rectangle {
                            width: parent.width * page.completed / Progress.achievements.length
                            height: parent.height
                            radius: parent.radius
                            color: "#92efd7"
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            ScrollView {
                id: entries
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 340
                contentWidth: availableWidth
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

                ColumnLayout {
                    width: entries.availableWidth - 12
                    spacing: 6
                    Repeater {
                        model: Progress.achievements
                        delegate: ActionButton {
                            id: entry
                            required property var modelData
                            readonly property int count: page.progress(modelData)
                            readonly property bool complete: count >= modelData.target
                            readonly property color progressColor: complete ? "#8cebd3" : "#83a6f0"
                            objectName: "achievement-" + modelData.id
                            Layout.fillWidth: true
                            implicitHeight: 47
                            text: modelData.title
                            primary: page.selected.id === modelData.id
                            Accessible.description: count + " of " + modelData.target
                            onClicked: page.selected = modelData

                            background: Rectangle {
                                radius: 6
                                color: entry.down ? "#303f59" : entry.primary ? "#25354a" : entry.hovered ? "#242e44" : "#191f2e"
                                border.color: entry.visualFocus ? "#f1f6ff" : entry.primary ? entry.progressColor : "#394862"
                                border.width: entry.primary || entry.visualFocus ? 2 : 1
                            }

                            contentItem: ColumnLayout {
                                spacing: 4
                                RowLayout {
                                    Text {
                                        Layout.preferredWidth: 14
                                        text: entry.complete ? "✓" : "◇"
                                        color: entry.progressColor
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        Layout.fillWidth: true
                                        text: entry.text
                                        color: "#edf3ff"
                                        font.family: "Inter"
                                        font.pixelSize: 13
                                        font.weight: entry.primary ? Font.DemiBold : Font.Normal
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: entry.count + " / " + entry.modelData.target
                                        color: "#b9cbe3"
                                        font.family: "IBM Plex Mono"
                                        font.pixelSize: 11
                                    }
                                }
                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 2
                                    color: "#3f4b65"
                                    Rectangle {
                                        width: parent.width * entry.count / entry.modelData.target
                                        height: parent.height
                                        color: entry.progressColor
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 470
                radius: 8
                color: "#1a2233"
                border.color: "#4c5d7a"

                ScrollView {
                    id: detailScroll
                    anchors.fill: parent
                    anchors.margins: page.compact ? 13 : 20
                    contentWidth: availableWidth
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    ColumnLayout {
                        id: details
                        width: detailScroll.availableWidth
                        spacing: page.compact ? 9 : 13

                        readonly property var unlock: page.reward(page.selected)
                        readonly property bool done: page.achievementsUnlocked || Progress.complete(page.profile, page.selected)
                        readonly property string rarity: page.selected.group === "pet" ? "Unique" : Gear.rarities[unlock.rarity].label
                        readonly property color rewardColor: page.selected.group === "pet" ? Pets.uniqueColor : Gear.rarities[unlock.rarity].color
                        readonly property string category: page.selected.group === "pet" ? "Pet" : unlock.category

                        Text {
                            text: details.done ? "✓ UNLOCKED" : "IN PROGRESS"
                            color: details.done ? "#7decc8" : "#a4bad1"
                            font.family: "IBM Plex Mono"
                            font.pixelSize: 12
                        }
                        Text {
                            Layout.fillWidth: true
                            text: page.selected.title
                            color: "#f2f6ff"
                            font.family: "Inter"
                            font.weight: Font.Bold
                            font.pixelSize: page.compact ? 23 : 29
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            Layout.fillWidth: true
                            text: page.selected.requirement
                            color: "#c0ccdd"
                            font.family: "Inter"
                            font.pixelSize: 15
                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            id: rewardCard
                            objectName: "achievementReward"
                            Layout.fillWidth: true
                            implicitHeight: rewardBody.implicitHeight + 20
                            radius: 8
                            border.width: 1
                            border.color: details.rewardColor
                            gradient: Gradient {
                                GradientStop { position: 0; color: Qt.tint("#202b3d", Qt.rgba(details.rewardColor.r, details.rewardColor.g, details.rewardColor.b, .17)) }
                                GradientStop { position: 1; color: "#171e30" }
                            }

                            ColumnLayout {
                                id: rewardBody
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: 10
                                spacing: 8

                                RowLayout {
                                    spacing: 10
                                    GalleryPortrait {
                                        Layout.preferredWidth: page.compact ? 96 : 136
                                        Layout.preferredHeight: page.compact ? 64 : 78
                                        border.color: "#485a74"
                                        entry: details.unlock
                                        tint: details.rewardColor
                                    }
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        Text {
                                            Layout.fillWidth: true
                                            text: details.rarity.toUpperCase() + " · " + details.category.toUpperCase()
                                            color: details.rewardColor
                                            font.family: "IBM Plex Mono"
                                            font.pixelSize: 11
                                            wrapMode: Text.WordWrap
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: details.unlock.title
                                            color: "#edf5ff"
                                            font.family: "Inter"
                                            font.weight: Font.Bold
                                            font.pixelSize: page.compact ? 16 : 20
                                            wrapMode: Text.WordWrap
                                        }
                                    }
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: details.unlock.description
                                    color: "#dfe8f7"
                                    font.family: "Inter"
                                    font.pixelSize: 14
                                    wrapMode: Text.WordWrap
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: details.done ? (page.selected.group === "pet" ? "Eligible for the pet draft at the start of a run."
                                : "Now eligible to appear in run rewards and shops.")
                                : (page.selected.group === "pet" ? "Unlocks this companion for future pet drafts." : "Unlocks this gear for future run rewards and shops.")
                            color: "#a7bed8"
                            font.family: "Inter"
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}

import QtQuick
import "../ui" as Ui
import "Encounters.js" as Mission
import "EnemyLore.js" as Lore

Ui.FieldHint {
    id:tip
    required property string enemyType
    required property var discoveries
    readonly property var spec:Mission.enemyTypes[enemyType] || Mission.enemyTypes.silophosus
    readonly property bool encountered:discoveries.includes(enemyType)
    chapter:"enemies"
    entryId:enemyType
    delay:180
    metadata:spec.origin+" · "+Mission.tier(spec.id)
    metadataTint:Lore.origins[spec.origin].color
    details:(encountered ? spec.title : "Unknown demon")
        +"\n"+(encountered ? Lore.whispers[spec.id] || spec.description : "Encounter it to reveal its field notes.")
}

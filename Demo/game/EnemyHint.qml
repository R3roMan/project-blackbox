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
    details:(encountered ? spec.title : "Unknown demon")+"\n"+spec.origin+" · "+Mission.tier(spec.id)
        +(encountered ? "\n"+(Lore.whispers[spec.id] || spec.description) : "\nEncounter it to reveal its field notes.")
}

import QtQml
import QtQml.Models

ListModel {
    id: roster
    required property var entries
    readonly property var records: ({})
    onEntriesChanged: sync()

    // Keep live model nodes in place when an unrelated enemy, projectile, or bag changes.
    function sync() {
        const present = new Map(entries.map(function(entry) { return [entry.id, entry] }))
        for (let i = count - 1; i >= 0; i -= 1) {
            const key = get(i).actorId
            if (present.get(key) !== records[key]) {
                remove(i)
                delete records[key]
            }
        }
        for (const entry of entries) {
            if (!records[entry.id]) {
                records[entry.id] = entry
                append({ actorId:entry.id })
            }
        }
    }
    Component.onCompleted: sync()
}

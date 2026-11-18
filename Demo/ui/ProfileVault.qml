import QtQuick
import QtCore
import "../game/Meta.js" as Meta

QtObject {
    id: vault
    objectName:"profileVault"
    required property url location
    property var state: Meta.fresh()
    component VaultSettings: Settings {
        category: "WitchVault"
    }
    readonly property VaultSettings storage: VaultSettings { location: vault.location }

    function reload() {
        storage.sync()
        state = Meta.read(String(storage.value("ledger", "")))
    }

    function replace(ledger) {
        if (!Meta.decode(ledger)) return false
        storage.setValue("ledger", JSON.stringify(ledger))
        storage.sync()
        state = ledger
        return true
    }

    function purchase(id) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        return Meta.buy(ledger,id) && replace(ledger)
    }

    function turnCard(id) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        return Meta.turnCard(ledger,id) && replace(ledger)
    }

    function reserve(id) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        const terms=Meta.begin(ledger,id)
        return terms && replace(ledger) ? terms : null
    }

    function alreadySettled(id) {
        reload()
        return !!state.settled[id]
    }

    function settle(report) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        if (!Meta.settle(ledger,report)) return false
        return replace(ledger)
    }

    function archive(report) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        if (!Meta.saveAttempt(ledger,report)) return false
        return replace(ledger)
    }

    Component.onCompleted: reload()
}

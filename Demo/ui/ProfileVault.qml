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

    function importLedger(ledger) {
        reload()
        if (!Meta.decode(ledger)) return false
        // A backup can restore the balance at export time. Completed attempts stay closed.
        ledger.closed=Object.assign({},ledger.closed,state.closed)
        for (const id of Object.keys(state.settled)) ledger.closed[id]=true
        return replace(ledger)
    }

    function purchase(id) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        return Meta.buy(ledger,id) && replace(ledger)
    }

    function refund(id) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        return Meta.refund(ledger,id) && replace(ledger)
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

    function deposit(id,claims) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        return Meta.depositField(ledger,id,claims) && replace(ledger)
    }

    function settle(report,legacyId) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        const awarded=Meta.settle(ledger,report)
        if (Meta.validId(report.id)) ledger.closed[report.id]=true
        if (Meta.validId(legacyId)) ledger.closed[legacyId]=true
        return replace(ledger) && awarded
    }

    function archive(report) {
        reload()
        const ledger=Meta.read(JSON.stringify(state))
        if (!Meta.saveAttempt(ledger,report)) return false
        return replace(ledger)
    }

    Component.onCompleted: reload()
}
